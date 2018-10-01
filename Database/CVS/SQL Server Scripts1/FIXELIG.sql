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


INSERT INTO #TPregMembers --store MemberRecId for later update on Group/ST_Group fields
SELECT  DISTINCT MemberRecID 
FROM PregClaims pc
WHERE MemberRecID not in (select distinct MemberRecID
FROM PregClaims pc where pc.IsNewbornCode = 1)--Get Members only if diagnosis on date are not newborn. 
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






--SELECT CS.AvetaID
--, CS.[Group]
--, CS.[ST_Group]
--,CS.IndValue
--, PME.IndEffectiveDate
--, PME.IndEndDate
--, C.CLAIMREFID
--, C.ServiceDateFrom
--, C.ServiceDateTo
--FROM    ENTERPRISEINTERFACES.CVS.CVSSQELETONLAYOUT AS CS
--        INNER JOIN
--        #TPREGMEMBERS AS PM
--        ON PM.MEMBERRECID = MEMBERID
--		INNER JOIN 
--		PregMembElig PME
--		ON CS.MEMBERID = PME.MEMBERRECID AND CS.IndValue = PME.IndValue
--        INNER JOIN
--        ENTERPRISEINTERFACES.CVS.PREGNANCYCOVEREDPLAN AS PREG
--        ON CS.INDVALUE = PREG.BENEFITPACKAGEID
--        INNER JOIN
--        ENTERPRISEHUB.DBO.CLAIM AS C
--        ON PM.MEMBERRECID = C.SUBSCRIBERMEMBERMREFID
--        LEFT OUTER JOIN
--        ENTERPRISEHUB.DBO.CLAIMDIAGNOSIS AS CD
--        ON CD.CLAIMREFID = C.CLAIMREFID
--        LEFT OUTER JOIN
--        ENTERPRISEHUB.MREF.DIAGNOSISCODE AS CODE
--        ON CODE.DIAGNOSISCODEMREFID = CD.DIAGNOSISCODEMREFID
--        INNER JOIN
--        ENTERPRISEINTERFACES.CVS.PREGNANCYANDNEWBORNCODES AS P
--        ON P.CODE = CODE.DIAGNOSISCODE
--WHERE   C.CLAIMSTATUSCODEMREFID NOT IN (5, 13) --HEADER STATUS NOT VOID
--        AND P.ISNEWBORNCODE <> 1
--        AND CS.CARRIER = PREG.CARRIER
--		AND CONVERT(DATE,C.ServiceDateFrom) BETWEEN CONVERT(DATE,PME.IndEffectiveDate) AND ISNULL(CONVERT(DATE,PME.IndEndDate),CONVERT(DATE,C.ServiceDateFrom))
	
	
		

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
		#PregMembElig PME
		ON CS.MEMBERID = PME.MEMBERRECID AND CS.IndValue = PME.IndValue
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
		AND CONVERT(DATE,C.ServiceDateFrom) BETWEEN CONVERT(DATE,PME.IndEffectiveDate) AND ISNULL(CONVERT(DATE,PME.IndEndDate),CONVERT(DATE,C.ServiceDateFrom))
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



SELECT  PKG.MemberRecId
, PKG.IndValue
, Pkg.IndEffectiveDate
, PKG.IndEndDate
, C.ClaimRefID
, C.ServiceDateFrom
, C.ServiceDateTo
FROM EnterpriseHub.dbo.MemberIndicator Pkg
	INNER JOIN EnterpriseHub.MRef.Company comp 
	ON comp.CompanyMRefId = Pkg.CompanyMRefId
	INNER JOIN ENTERPRISEHUB.DBO.CLAIM C
	ON PKG.MemberRecId = C.SUBSCRIBERMEMBERMREFID
WHERE 1=1 
	AND Pkg.IndMRefId = 24	
	AND Pkg.MemberRecId IN(573689)
	AND C.ClaimRefID = 73739834
	AND CONVERT(DATE,C.ServiceDateFrom) BETWEEN CONVERT(DATE,Pkg.IndEffectiveDate) AND ISNULL(CONVERT(DATE,PKG.IndEndDate),CONVERT(DATE,C.ServiceDateFrom))
;


	SELECT PKG.MemberRecId
	, PKG.IndValue
	, Pkg.IndEffectiveDate
	, PKG.IndEndDate
	, C.ClaimRefID
	, C.ServiceDateFrom
	, C.ServiceDateTo
	FROM EnterpriseHub.dbo.MemberIndicator Pkg
		INNER JOIN EnterpriseHub.MRef.Company comp 
		ON comp.CompanyMRefId = Pkg.CompanyMRefId
		INNER JOIN ENTERPRISEHUB.DBO.CLAIM C
		ON PKG.MemberRecId = C.SUBSCRIBERMEMBERMREFID
		INNER JOIN #TPREGMEMBERS AS PM
        ON PKG.MemberRecId = PM.MEMBERRECID
	WHERE 1=1 
		AND Pkg.IndMRefId = 24	
		--AND Pkg.MemberRecId IN(573689)
		--AND C.ClaimRefID = 73739834
		AND CONVERT(DATE,C.ServiceDateFrom) BETWEEN CONVERT(DATE,Pkg.IndEffectiveDate) AND ISNULL(CONVERT(DATE,PKG.IndEndDate),CONVERT(DATE,C.ServiceDateFrom))