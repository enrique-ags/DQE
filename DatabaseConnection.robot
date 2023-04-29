*** Settings ***
Documentation  Database Testing in robot framework 
Library  DatabaseLibrary
Library  OperatingSystem


*** Variables ***

${DB_NAME}  AdventureWorks2019
${DB_USER}  robot
${DB_Password}  12345
${DB_Host}  DESKTOP-M531GVI
${DB_Port}  1433

*** Keywords ***
Connect DB
    Connect To Database   pymssql  ${DB_NAME}  ${DB_USER}  ${DB_Password}  ${DB_Host}  ${DB_Port}  

*** Test Cases ***
Verify row count is 26 for postal code 98011
    Connect DB
    [documentation]  This testcase verifies that postal code 98011 has a row count equal to 26
    
    Execute Sql String  Select count(*) from AdventureWorks2019.Person.Address   where PostalCode = '98011' 26
    
Verify row count is 7 for postal code 75201
    Connect DB
    [documentation]  This testcase verifies that postal code 75201 has a row count equal to 7
    
    Execute Sql String  Select count(*) from AdventureWorks2019.Person.Address   where PostalCode = '75201' 7
    
Verify a Table is present or Not
    [documentation]  This testcase verifies a tables exists within DB
    Table Must Exist  Store

Verify the unitary price is different to Zero in table PurchaseOrderDetail. if there is a unit price equal to Zero it is an error
    [documentation]  this testcase verifies the unitary price is different to Zero in table PurchaseOrderDetail
    Row Count Is Equal To X  Select UnitPrice from [Purchasing].[PurchaseOrderDetail] where UnitPrice = 0  0

Verify Successful creation of table
    [documentation]  this test case verifies that user is able to create a table successfully
    ${output}=  Execute Sql String  Create table PersonsTest(PersonID int, FirstName varchar(255));
    Should Be Equal As Strings  ${output}  None 



