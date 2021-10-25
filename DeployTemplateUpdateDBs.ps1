# Getting input from terminal
# $filename = $args[$filename] #Read-Host("Enter filename: ")
# $dbs =  $args[$dbs]     #Read-Host("Enter dbs: ")
# $extname = $args[$extname]  #Read-Host("Enter extname: ")
param ($filename, $dbs, $extname)
if($extname -match '([ _]).*')
{
    Write-Host 'Space and underscore characters are not allowed'
    exit
}

Write-Host $filename
Write-Host $dbs
Write-Host $extname

# get file and modify
#absolute path
#$filePathToTask ="D:\TemplateUpdateDBs\InstanceTemplate.azure.deploy.sit.xml""
#relative path
$filePathToTask ="..\TemplateUpdateDBs\InstanceTemplate.azure.deploy.sit.xml"
$xml = New-Object XML
$xml.Load($filePathToTask)

#$elements = '';
$foundNode = $xml.SelectSingleNode('//Instance/components/database[@id="Database"]')
For ($i = 1; $i -lt $dbs; $i++)  
{
    $count = "{0:00}" -f $i
    $tags = "<database id='Database$count' depends='Innovator SelfServiceReporting Vault Conversion Agent OAuth'>"
    $tags = $tags + '<SqlServer>${MSSQL.Server}</SqlServer>'
    $tags = $tags + "<DatabaseName>student-$count-$extname</DatabaseName>"
    $tags = $tags + "<DbConnectionId>student-$count</DbConnectionId>"
    $tags = $tags + '<InnovatorLogin>${MSSQL.Innovator.User}</InnovatorLogin>'
    $tags = $tags + '<InnovatorPassword type="EnvironmentVariable">MSSQL.Innovator.Password</InnovatorPassword>'
    $tags = $tags + '<InnovatorUrl>${Innovator.Load.Balancer.Url}/${Name.Of.Innovator.Instance}</InnovatorUrl>'
    $tags = $tags + '</database>'
 
    $newNode = [xml]$tags
    $newNode = $xml.ImportNode($newNode.database,$true)
    
    $components = $xml.Instance.components
    $components.InsertAfter($newNode,$foundNode) |out-null  

    $foundNode = $xml.SelectSingleNode("//Instance/components/database[@id='Database$count']")
}


 $xml.Save($filePathToTask)