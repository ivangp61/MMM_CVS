USE EnterpriseInterfaces;

IF ((SELECT COUNT(*) FROM sys.tables WHERE name = 'CVSSqeleton_Staging_Language') > 0) 
	DROP TABLE CVS.CVSSqeleton_Staging_Language;