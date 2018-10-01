
with CVSCAG as 
(
      SELECT [BenefitPkgXRefId]
              ,[Carrier]
              ,[Account]
              ,[GroupNumber]
              ,[GroupName]
              ,[Bin]
              ,[RxPCN]
              ,[RxGroup]
              ,[MatchOn]
              ,[SentFile]
        FROM [EnterpriseHub].[CVS].[Cag]
        WHERE [Carrier] IS NOT NULL
          AND [Carrier] LIKE '8%'    
        
      UNION
  
      SELECT [BenefitPkgXRefId]
              ,SecCarrier AS [Carrier] 
              ,SecAccount AS [Account]  
              ,SecGroupNumber AS [GroupNumber]
              ,SecGroupName AS [GroupName]
              ,[Bin]
              ,[RxPCN]
              ,[RxGroup]
              ,[MatchOn]
              ,[SentFile]
        FROM [EnterpriseHub].[CVS].[Cag]  
        WHERE SecCarrier IS NOT NULL
          AND SecCarrier LIKE '3%'
)


select	
		convert(char(1),'3') as RecordType
		,CONVERT(char(9),Cag.Carrier) as Carrier
		,convert(char(15),Cag.Account) as Account
		,convert(char(15),upper(Cag.[GroupNumber])) as [Group]
		,convert(char(18),coalesce(XM.ExternalValue,'')) as AvetaID	
		,convert(char(3),coalesce('01','')) as PersonCode
		,convert(char(1),'1') as Relationship
		,convert(char(25),coalesce(Upper(MC.LastName),'')) as LastName
		,convert(char(15),coalesce(Upper(MC.FirstName),'')) as FirstName 
		,convert(char(1),coalesce(MC.MiddleName,'')) as MiddleName 
		,case when MC.GenderMRefId = 1
			then CONVERT(char(1),'F')
			else CONVERT(char(1),'M')
		end SexCode
		,convert(char(8),isnull(convert(char(8),MC.BirthDate,112),'00000000')) as DateOfBirth
		,convert(char(1),'0') as MultiBirthCode
		,convert(char(1),'') as MemberType
		,case when MC.LanguageMRefId = 22
			then convert(char(1),'1')
			else convert(char(1),'3') 
		End as LanguageCode
		,convert(char(1),'') as DURFlag
		,convert(char(18),'') as DURKey
		,convert(char(9),'000000000') as SocialSecurity
		,convert(char(40),coalesce(MA.AddrLine1,'')) as AddrLine1
		,convert(char(40),coalesce(MA.AddrLine2,'')) as AddrLine2
		,convert(char(20),coalesce(MA.AddrCity,'')) as AddrCity
		,convert(char(2),coalesce(MA.AddrState,'')) as AddrState
		,convert(char(5),coalesce(MA.AddrZipCode,'')) as AddrZipCode
		,convert(char(4),coalesce(MA.AddrZip4Code,'')) as AddrZip4Code
		--,SPACE(2) as ZipCode3
		,CONVERT(char(2),'99') as ZipCode3
		,convert(char(4),coalesce('USA','')) as Country
		,convert(char(10),coalesce(MCOMMD.CommValue,'')) as PhoneNumber
		--,SPACE(1) as FamilyFlag
		,CONVERT(char(1),'') as FamilyFlag
		--,SPACE(1) as FamilyType
		,CONVERT(char(1),'') as FamilyType
		,convert(char(18),coalesce(XM.ExternalValue,'')) as FamilyID-- AvetaNumber
		,convert(char(7),'0000000') as OriginalDateFrom
		,convert(char(7),'0000000') as BenefitResetDate
		,convert(char(7), '1' + CONVERT(CHAR(7), isnull(MI.IndEffectiveDate,''), 12)) AS FechaEligibilidad --fecha elibilidad
				,convert(char(7), '1' + CONVERT(CHAR(7), isnull(
		case 		when isnull(MI.IndEndDate,'2039-12-31') = MI.IndEffectiveDate then DATEADD(day, -1, MI.IndEndDate) 
		else MI.IndEndDate
		end ,'391231'), 12)) 
		AS FechaTerminacion --[YYMMDD] --fecha terminacion eligibilidad
		,CONVERT(char(10),'') as [Plan]
		,convert(char(7),'0000000') as PlanEffectiveDate
		,convert(char(5),'00000') as Brand
		,convert(char(5),'00000') as Generic
		,convert(char(5),'00000') as Copay3
		,convert(char(5),'00000') as Copay4
		,convert(char(6),'') as ClientProductCode
		,convert(char(6),'') as ClientRiderCode
		,convert(char(7),'0000000') as CareFromDate
		,convert(char(7),'0000000') as CareThruDate
		,convert(char(10),'') as CareNetwork
		,convert(char(10),'') as CareNetworkPlanOvr
		,convert(char(7),'0000000') as CareNetworkPlanFrm
		,convert(char(6),'') as CareFacility
		,convert(char(10),'') as CareQualifier
		,convert(char(10),'') as PCPNPI
		,convert(char(7),'0000000') as AltInsFromDate
		,convert(char(7),'0000000') as AltInsThruDate
		,convert(char(1),'') as AltInsIndicator
		,convert(char(10),'') as AltInsCode
		,convert(char(18),'') as AltInsMemberID
		--,space(1) as NewCardFlag
		,CONVERT(char(1),'') as NewCardFlag
		,convert(char(1),'') as FSAIndicator
		,convert(char(1),'') as GracePeriodIndicator
		,convert(char(7),'') as GracePeriodInfEffDate
		,convert(char(1),'') as MedCoverageType
		,convert(char(7),'0000000') as MedFromDate
		,convert(char(11),REPLACE(REPLACE(REPLACE( isnull(XMH.ExternalValue,''),CHAR(13),''),CHAR(10),''), CHAR(0), '') ) as HicNumber
		,convert(char(6),'') as DiagnosisCode1		
		,convert(char(6),'') as DiagnosisCode2		
		,convert(char(6),'') as DiagnosisCode3		
		,convert(char(6),'') as DiagnosisCode4		
		,convert(char(6),'') as DiagnosisCode5		
		,convert(char(6),'') as DiagnosisCode6		
		--,SPACE(6) as DiagnosisCode7	
		,convert(char(6),'') as DiagnosisCode7	
		,convert(char(6),'') as DiagnosisCode8		
		,convert(char(6),'') as DiagnosisCode9
		,convert(char(6),'') as DiagnosisCode10		
		,convert(char(3),'') as AllergyCode1
		,convert(char(3),'') as AllergyCode2
		,convert(char(3),'') as AllergyCode3
		,convert(char(3),'') as AllergyCode4
		,convert(char(3),'') as AllergyCode5
		,convert(char(3),'') as AllergyCode6
		,convert(char(5),'00000') as Height
		,convert(char(5),'00000') as [Weight]
		,convert(char(1),'') as BlodType
		,convert(char(1),'') as ContactLensCode
		,convert(char(1),'') as SmokingCode
		,convert(char(1),'') as PregnancyCode
		,convert(char(1),'') as AlcoholCode
		,convert(char(1),'') as MiscCode1
		,convert(char(1),'') as MiscCode2
		,convert(char(7),'0000000') as CDDEffDate
		,convert(char(7),'0000000') as CDDtermDate
		,convert(char(256),'') as CDD
		,convert(char(1),'') as AccumulationFamilyType
		,convert(char(1),'') as OverrideDeductibleProrate
		,convert(char(1),'') as OverrideHSAProrate
		,convert(char(7),'0000000') as ProrationDate
		,convert(char(97),'') as Filler1
		,convert(char(20),'') as ThirdID
		,convert(char(2),'') as ThirdIDTypeCode
		,convert(char(1),'0') as MedicareParticipationIndicator --Update with 0 or if platino then blank
		,convert(char(1),'') as Filler2
		,CONVERT(CHAR(8), isnull(MI.IndEffectiveDate,''), 112) as MedicareParticipationEventDate
		,convert(char(9),'') as Filler3
		,convert(char(18),'') as CrosswalkMemberId
		,convert(char(2),'') as Filler4
		,convert(char(1),'') as Filler5
		,convert(char(12),REPLACE(REPLACE(REPLACE(isnull(XMH.ExternalValue,'0000000000'),CHAR(13),''),CHAR(10),''), CHAR(0), '') ) as Hic
		--coalesce(XMH.ExternalValue,'0000000000')) as Hic
		
		,convert(char(3),'000') as LICSPremiumSubLevel

		,CONVERT(char(5), COALESCE(BP.CompanyContract,''))  AS ContractId
		,convert(char(3),'') as CMSPlanID
		,convert(char(30),'') as CaretakerFirstName
		,convert(char(30),'') as CaretakerLastName
		,convert(char(30),'') as CaretakerAddress1
		,convert(char(30),'') as CaretakerAddress2
		,convert(char(30),'') as CaretakerCity
		,convert(char(2),'') as CaretakerState
		,convert(char(9),'') as CaretakerZip
		-----------------------------------
		---Platino File members Link
		,convert(char(9),'') as ST_Carrier
		,convert(char(15),'') as ST_Account
		,convert(char(15),'') as ST_Group
		,convert(char(18),'') as ST_MemberID
		,convert(char(1),'') as ST_Status
		,convert(char(1),'') as ST_COB
		------------------------------------
		,convert(char(7),'0000000') as TransitionPeriodStartDate
		,convert(char(7),'0000000') as TransitionPeriodStartDateInactiveDate
		,convert(char(7),'') as ESRDFromDate --Update ESRD Data
		,convert(char(7),'') as ESRDThruDate --Update ESRD Data
		,convert(char(7),'') as DialysisFromDate
		,convert(char(7),'') as DialysisThruDate
		,convert(char(7),'') as TransplantFromDate --Update Transplant Data
		,convert(char(7),'') as TransplantThruDate --Update Transplant Data
		,convert(char(7), '1' + CONVERT(CHAR(7), isnull(MI.IndEffectiveDate,''), 12)) AS MBRPartBFlagFromDate --[YYMMDD] --fecha elibilidad
				,convert(char(7), '1' + CONVERT(CHAR(7), isnull(case 		when isnull(MI.IndEndDate,'2039-12-31') = MI.IndEffectiveDate then DATEADD(day, -1, MI.IndEndDate) 
		else MI.IndEndDate
		end ,'391231'), 12))  AS MBRPartBFlagThruDate --[YYMMDD] --fecha terminacion eligibilidad
		,convert(char(1),'') as MemberLanguagePrintFormatCode
		,convert(char(7),'') as MBRHospiceFromDate --Update Hospice Data
		,convert(char(7),'') as MBRHospiceThruDate --Update Hospice Data
		,convert(char(11),'') as Filler6
		,convert(char(20),'') as QLClient
		,'*' as EOR
		,MI.IndValue --package ID
		,'0' as IsPlatino
		,'0' as IsMA
		,convert(char(18),coalesce(MI.MemberRecId,'')) as MemberID
		,MPCP.ProviderRecId
		,CAG.SentFile as SentFile
		
from EnterpriseHub.dbo.MemberIndicator MI
inner join EnterpriseHub.dbo.MemberCompany MC
	on MI.MemberRecId = MC.MemberRecId
	and MI.IndMRefId = 24 
	and (ISNULL(MI.IndEndDate,GETDATE()) >= '01/01/2014') 	
	
left join EnterpriseHub.dbo.MemberAddress MA
	on MI.MemberRecId = MA.MemberRecId
	and MA.AddrTypeMRefId = 7
	and LEN(MA.AddrLine1) > 0
left join EnterpriseHub.dbo.MemberCommunication MCOMM
	on MI.MemberRecId = MCOMM.MemberRecId
	and MCOMM.CommTypeMRefId = 7
left join EnterpriseHub.dbo.MemberCommunicationDetail MCOMMD
	on MCOMM.CommDetailRecId = MCOMMD.CommDetailRecId
inner join EnterpriseHub.XRef.Member XM --Aveta
	on MI.MemberRecId = XM.MemberRecId
	and XM.ExternalTypeMRefId = 5
left join EnterpriseHub.XRef.Member XMH --HIC Number
	on MI.MemberRecId = XMH.MemberRecId
	and XMH.ExternalTypeMRefId = 11
left join EnterpriseHub.dbo.MemberPCP MPCP
	on MI.MemberRecId = MPCP.MemberRecId
	and ISNULL(MPCP.PCPEndDate,getdate()) >= GETDATE()
left join EnterpriseHub.XRef.Provider XP
	on MPCP.ProviderRecId = XP.ProviderRecId
	and XP.ExternalTypeMRefId = 13
	
 -- NEW RELATIONSHIP
	INNER JOIN EnterpriseHub.XRef.BenefitPackage BP ON BP.SORId = MI.IndValue 												
	INNER JOIN CVSCag CAG ON CAG.[BenefitPkgXRefId] = BP.[BenefitPkgXRefId] 			
			--AND Cag.PackageId is not null 
			
			--AND Cag.ContractId = BP.BenefitPkgContractId 
			--AND Cag.ContractId != ''
	
where 1=1	
	and XM.ExternalValue = '010035000'
order by AvetaID,FechaEligibilidad,FechaTerminacion asc







select	MI.IndValue
--,CAG.[BenefitPkgXRefId]
, MC.*		
from EnterpriseHub.dbo.MemberIndicator MI
inner join EnterpriseHub.dbo.MemberCompany MC
	on MI.MemberRecId = MC.MemberRecId
	--and MI.IndMRefId = 24 
	and (ISNULL(MI.IndEndDate,GETDATE()) >= '01/01/2014') 	
	
 -- NEW RELATIONSHIP
	--INNER JOIN EnterpriseHub.XRef.BenefitPackage BP ON BP.SORId = MI.IndValue 												
	--INNER JOIN CVSCag CAG ON CAG.[BenefitPkgXRefId] = BP.[BenefitPkgXRefId] 				
where 1=1	
	AND MI.MemberRecId = 42730

--	and XM.ExternalValue = '010035000'
