USE [EnterpriseInterfaces]
GO
/****** Object:  StoredProcedure [CVS].[E006_ExtractElegibilityDetailDataPlatino]    Script Date: 12/14/2016 6:27:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Keiny J Grau
-- Create date: 10/08/2013
-- Description:	This sp will Create A table for thr ESRD Members
--exec [CVS].[E006_ExtractElegibilityDetailDataPlatino]
-- Update: Alejandro Diaz y Jose Castro
-- Update: 10/12/2015
-- =============================================
ALTER PROCEDURE [CVS].[E006_ExtractElegibilityDetailDataPlatino] 	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--update CVSSqeletonLayout
	--set 	ST_Status = 'A',
	--	ST_COB = '2'
	--WHERE SentFile in (0,2);

	--------------------------Update Medicare Indicator------------------------
	update CVS.CVSSqeletonLayout 
	set MedicareParticipationIndicator = convert(char(1),'')
	where isMA <> '1';
	

	--------------------------------Others Update ------------------------------------
	--update CVS.CVSSqeletonLayout
	--set ContractId = convert(char(5),''),
	--CMSPlanID = convert(char(5),'');
	
	--update CVS.CVSSqeletonLayout
	--set MedicareParticipationIndicator = convert(char(1),'');
	
	with ST_MemberLines as 
	(
		select 
		Account
		,[Group]
		,AvetaID
		,Carrier
		,FechaEligibilidad
		,FechaTerminacion
		,IndValue
		from CVS.CVSSqeletonLayout SL
		where Carrier like '3%'
	)
	update CVS.CVSSqeletonLayout
	set ST_Carrier = PL.Carrier,
		ST_Account = PL.Account,
		ST_Group = PL.[Group],
		ST_MemberID = PL.AvetaID,
		ST_Status = 'A',
		ST_COB = '2'
	from ST_MemberLines PL
	Inner Join CVS.CVSSqeletonLayout SL
	On SL.Account = PL.Account
	and SL.[Group] = PL.[Group]
	and SL.AvetaID =  PL.AvetaID
	and SL.Carrier <> PL.Carrier
	and SL.Carrier like '8%'
	and SL.FechaEligibilidad = PL.FechaEligibilidad
	and SL.FechaTerminacion = PL.FechaTerminacion
	and sl.IndValue  = PL.IndValue
	where ST_Account = ''
	--and AltInsIndicator = 'Y'
	--on SL.AvetaID =  PL.AvetaID
	--and PL.SentFile in (0,2)
	--PL.isPlatino = '1'
	--where SL.Account = PL.Account
	--and SL.[Group] = PL.[Group]
	
--***************PREGNANCY INDICATOR QUERY***********************************

	IF OBJECT_ID('tempdb.dbo.#TPregMembers', 'U') IS NOT NULL
	  DROP TABLE #TPregMembers; 

	Create table #TPregMembers
		(MemberRecId int); 

	IF OBJECT_ID('tempdb.dbo.#PregMembElig', 'U') IS NOT NULL
	  DROP TABLE #PregMembElig;

	Create table #PregMembElig
	(
		MemberRecId int,
		IndEffectiveDate datetime,
		IndEndDate datetime,
		IndValue varchar(20)
	)
	;


	with PregMembers as --get members in file that are in pregnancy covered plans
	(
		select distinct MemberID --,datediff( year,convert(char(8),replace(cs.DateOfBirth,'00000000','19000101'),120), getdate())
		from CVS.CVSSqeletonLayout cs
		Inner Join EnterpriseInterfaces.CVS.PregnancyCoveredPlan preg
		On cs.IndValue = preg.BenefitPackageID
		where cs.SexCode = 'F'--Females only
		and DATEDIFF(year, convert(char(8),replace(cs.DateOfBirth,'00000000','19000101'),120),GETDATE())<=60--Age 60 Years or younger
	)

	,PregClaims as 
	(--Get latest Claim with pregnancy diagnosis
		SELECT  C.SubscriberMemberMRefID MemberRecID, 
		MAX(C.ReceivedDate)ReceivedDate, 
		c.ClaimRefID, P.CODE, 
		P.IsNewbornCode
		--,C.ReceivedDate ,C.ClaimRefID,code.DiagnosisCodeMRefID,CODE.DiagnosisCode, CODE.Description 
		FROM EnterpriseHub.dbo.Claim C
		Inner Join PregMembers pm
		On pm.MemberID = C.SubscriberMemberMRefID
		left JOIN EnterpriseHub.dbo.ClaimDiagnosis CD 
			ON CD.ClaimRefID = C.ClaimRefID 
		left JOIN EnterpriseHub.MRef.DiagnosisCode CODE 
			ON CODE.DiagnosisCodeMrefId = CD.DiagnosisCodeMRefId 
		Inner Join EnterpriseInterfaces.CVS.PregnancyAndNewBornCodes P
		On	P.CODE = CODE.DiagnosisCode 
		where C.ServiceDateFrom >= dateadd(month,-9, GETDATE()) --Claims in the last 9 months
		and C.ClaimStatusCodeMRefID not in (5,13)--header status not VOID
	 group by C.ClaimRefID, C.SubscriberMemberMRefID, P.CODE, P.IsNewbornCode
	)

	Insert into #TPregMembers --store MemberRecId for later update on Group/ST_Group fields
	SELECT  distinct MemberRecID 
	FROM    PregClaims pc
	where  MemberRecID not in (select distinct MemberRecID
	FROM    PregClaims pc where pc.IsNewbornCode = 1)--Get Members only if diagnosis on date are not newborn. 
	;		

	INSERT INTO #PregMembElig(MemberRecId, IndEffectiveDate, IndEndDate, IndValue)
	SELECT PKG.MemberRecId, Pkg.IndEffectiveDate, PKG.IndEndDate, PKG.IndValue
	FROM EnterpriseHub.dbo.MemberIndicator Pkg
		INNER JOIN EnterpriseHub.MRef.Company comp 
		ON comp.CompanyMRefId = Pkg.CompanyMRefId
		INNER JOIN #TPREGMEMBERS AS PM
		ON PKG.MemberRecId = PM.MEMBERRECID
	WHERE 1=1 
		AND Pkg.IndMRefId = 24
	;


	update EnterpriseInterfaces.CVS.CVSSqeletonLayout 
	set [ST_Group] =
			CASE WHEN  YEAR(C.SERVICEDATEFROM) < 2017
				 THEN	 PregGroupName  --SET PREGNACNCY FIELD CODE
				 ELSE [ST_Group]
			END --Set primary file ST_Group with pregnancy groupname
	from EnterpriseInterfaces.CVS.CVSSqeletonLayout cs
			Inner Join #TPregMembers pg
				On pg.MemberRecId = MemberID 
			INNER JOIN 
			#PregMembElig PME
			ON CS.MEMBERID = PME.MEMBERRECID AND CS.IndValue = PME.IndValue
			Inner Join EnterpriseInterfaces.CVS.PregnancyCoveredPlan preg
				On cs.IndValue = preg.BenefitPackageID
			INNER JOIN ENTERPRISEHUB.DBO.CLAIM AS C
				ON pg.MEMBERRECID = C.SUBSCRIBERMEMBERMREFID
			LEFT OUTER JOIN ENTERPRISEHUB.DBO.CLAIMDIAGNOSIS AS CD
				ON CD.CLAIMREFID = C.CLAIMREFID
			LEFT OUTER JOIN ENTERPRISEHUB.MREF.DIAGNOSISCODE AS CODE
				ON CODE.DIAGNOSISCODEMREFID = CD.DIAGNOSISCODEMREFID
			INNER JOIN ENTERPRISEINTERFACES.CVS.PREGNANCYANDNEWBORNCODES AS P
				ON P.CODE = CODE.DIAGNOSISCODE
	where cs.Carrier = preg.PrimaryCarrier
		AND C.SERVICEDATEFROM <= preg.TerminationDate
		AND CONVERT(DATE,C.ServiceDateFrom) BETWEEN CONVERT(DATE,PME.IndEffectiveDate) AND ISNULL(CONVERT(DATE,PME.IndEndDate),CONVERT(DATE,C.ServiceDateFrom))
		;

	update EnterpriseInterfaces.CVS.CVSSqeletonLayout 
	set [Group] = 	
			CASE WHEN  YEAR(C.SERVICEDATEFROM) < 2017
				 THEN	 PregGroupName  --SET PREGNACNCY FIELD CODE
				 ELSE [Group]
			END--Set secondary file Group with pregnancy groupname
		from EnterpriseInterfaces.CVS.CVSSqeletonLayout cs
			Inner Join #TPregMembers pg 
			On pg.MemberRecId = MemberID 
			INNER JOIN 
			#PregMembElig PME
			ON CS.MEMBERID = PME.MEMBERRECID AND CS.IndValue = PME.IndValue
			Inner Join EnterpriseInterfaces.CVS.PregnancyCoveredPlan preg
			On cs.IndValue = preg.BenefitPackageID
			INNER JOIN ENTERPRISEHUB.DBO.CLAIM AS C
			ON pg.MEMBERRECID = C.SUBSCRIBERMEMBERMREFID
			LEFT OUTER JOIN ENTERPRISEHUB.DBO.CLAIMDIAGNOSIS AS CD
			ON CD.CLAIMREFID = C.CLAIMREFID
			LEFT OUTER JOIN ENTERPRISEHUB.MREF.DIAGNOSISCODE AS CODE
			ON CODE.DIAGNOSISCODEMREFID = CD.DIAGNOSISCODEMREFID
			INNER JOIN ENTERPRISEINTERFACES.CVS.PREGNANCYANDNEWBORNCODES AS P
			ON P.CODE = CODE.DIAGNOSISCODE
	where cs.Carrier = preg.Carrier
		AND C.SERVICEDATEFROM <= preg.TerminationDate
		AND CONVERT(DATE,C.ServiceDateFrom) BETWEEN CONVERT(DATE,PME.IndEffectiveDate) AND ISNULL(CONVERT(DATE,PME.IndEndDate),CONVERT(DATE,C.ServiceDateFrom))
		;
	
	IF OBJECT_ID('tempdb.dbo.#PregMembers', 'U') IS NOT NULL
  DROP TABLE #TPregMembers;
END
