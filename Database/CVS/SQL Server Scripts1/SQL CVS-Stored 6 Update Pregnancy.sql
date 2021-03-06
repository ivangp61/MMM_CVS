USE [EnterpriseInterfaces]
GO
/****** Object:  StoredProcedure [CVS].[E006_ExtractElegibilityDetailDataPlatino]    Script Date: 12/1/2016 10:54:11 AM ******/
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

----------------------------------------------------------------------------------------
-- Request: 1662-7843
-- Date   : 11/02/2016 
-- Remarks: To update the Pregnancy Code 
----------------------------------------------------------------------------------------
UPDATE  ENTERPRISEINTERFACES.CVS.CVSSQELETONLAYOUT
		SET PREGNANCYCODE =
		CASE WHEN  YEAR(C.SERVICEDATEFROM) < 2017
			 THEN	 'Y'  --SET PREGNACNCY FIELD CODE
			 ELSE   ' '
		END 
FROM    ENTERPRISEINTERFACES.CVS.CVSSQELETONLAYOUT AS CS
        INNER JOIN
        #TPREGMEMBERS AS PM
        ON PM.MEMBERRECID = MEMBERID
        INNER JOIN
        ENTERPRISEINTERFACES.CVS.PREGNANCYCOVEREDPLAN AS PREG
        ON CS.INDVALUE = PREG.BENEFITPACKAGEID
        INNER JOIN
        ENTERPRISEHUB.DBO.CLAIM AS C
        ON PM.MEMBERRECID = C.SUBSCRIBERMEMBERMREFID
        LEFT OUTER JOIN
        ENTERPRISEHUB.DBO.CLAIMDIAGNOSIS AS CD
        ON CD.CLAIMREFID = C.CLAIMREFID
        LEFT OUTER JOIN
        ENTERPRISEHUB.MREF.DIAGNOSISCODE AS CODE
        ON CODE.DIAGNOSISCODEMREFID = CD.DIAGNOSISCODEMREFID
        INNER JOIN
        ENTERPRISEINTERFACES.CVS.PREGNANCYANDNEWBORNCODES AS P
        ON P.CODE = CODE.DIAGNOSISCODE
WHERE   C.CLAIMSTATUSCODEMREFID NOT IN (5, 13) --HEADER STATUS NOT VOID
        AND P.ISNEWBORNCODE <> 1
        AND CS.CARRIER = PREG.CARRIER

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------

update EnterpriseInterfaces.CVS.CVSSqeletonLayout 
set [ST_Group] = PregGroupName --Set primary file ST_Group with pregnancy groupname
from EnterpriseInterfaces.CVS.CVSSqeletonLayout cs
Inner Join #TPregMembers pg
	On pg.MemberRecId = MemberID 
Inner Join EnterpriseInterfaces.CVS.PregnancyCoveredPlan preg
	On cs.IndValue = preg.BenefitPackageID
where cs.Carrier = preg.PrimaryCarrier

update EnterpriseInterfaces.CVS.CVSSqeletonLayout 
set [Group] = PregGroupName --Set secondary file Group with pregnancy groupname
from EnterpriseInterfaces.CVS.CVSSqeletonLayout cs
Inner Join #TPregMembers pg
On pg.MemberRecId = MemberID 
Inner Join EnterpriseInterfaces.CVS.PregnancyCoveredPlan preg
On cs.IndValue = preg.BenefitPackageID
where cs.Carrier = preg.Carrier
	
	IF OBJECT_ID('tempdb.dbo.#PregMembers', 'U') IS NOT NULL
  DROP TABLE #TPregMembers;
END
