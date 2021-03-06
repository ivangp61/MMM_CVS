SELECT *
FROM ENTERPRISEHUB.DBO.CLAIMDIAGNOSIS CD



SELECT CASE 
			WHEN (YEAR(C.SERVICEDATEFROM) < 2017)
			 THEN PREGNANCYCODE = 'Y' --SET PREGNACNCY FIELD CODE
			 ELSE PREGNANCYCODE = ''
	END AS PCODE
FROM    ENTERPRISEINTERFACES.CVS.CVSSQELETONLAYOUT AS CS
        INNER JOIN
        #TPREGMEMBERS AS PM
        ON PM.MEMBERRECID = 
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
WHERE   
        AND C.CLAIMSTATUSCODEMREFID NOT IN (5, 13) --HEADER STATUS NOT VOID
        AND P.ISNEWBORNCODE <> 1
        AND CS.CARRIER = PREG.CARRIER

SELECT AvetaID, MemberID
FROM EnterpriseInterfaces.CVS.CVSSqeletonLayout S
WHERE  
--s.AvetaID = '010054917'
PREGNANCYCODE = 'Y'
;


SELECT COUNT(*)
FROM EnterpriseInterfaces.CVS.CVSSqeletonLayout S
WHERE PREGNANCYCODE = 'Y'
--1345019
--10

SELECT AvetaID,Carrier,[GROUP],[ST_Group],PregnancyCode, S.FechaEligibilidad,FechaTerminacion, IndValue
FROM EnterpriseInterfaces.CVS.CVSSqeletonLayout S WITH(NOLOCK)
WHERE s.AvetaID IN('010497801')--'010585502')

SELECT *
FROM [EnterpriseInterfaces].[CVS].[PregnancyCoveredPlan]


'010273005',         
'010497801',         
'030191491',         
'010450362',         
'010501213',         
'010697421')
--'030075420'
order by AvetaID
PREGNANCYCODE = 'Y'

               
			   
               
SELECT *
FROM [EnterpriseInterfaces].[CVS].[PregnancyCoveredPlan]

SELECT *
FROM EnterpriseInterfaces.CVS.CVSSqeletonLayout 
               

SELECT *
FROM EnterpriseHub.dbo.MemberCompany MC
WHERE MC.MemberRecId = 112334


--update EnterpriseHub.dbo.MemberCompany
set birthdate = '1957-09-27 00:00:00.000'
WHERE MemberRecId = 112334
;
