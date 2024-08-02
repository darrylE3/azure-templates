param adminUsername string = resourceGroup().name
@secure()
param adminPassword string

var name = resourceGroup().name
var location = resourceGroup().location

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: name
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
  }

  resource sqlDatabase 'databases' = {
    name: name
    location: location
    sku: {
      name: 'Basic'
      tier: 'Basic'
      capacity: 5
    }
    properties: {
      collation: 'SQL_Latin1_General_CP1_CI_AS'
      isLedgerOn: false
      catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
      requestedBackupStorageRedundancy: 'Geo'
    }
  }

  resource firewall_AllowAllWindowsAzureIps 'firewallRules' = {
    name: 'AllowAllWindowsAzureIps'
    properties: {
      startIpAddress: '0.0.0.0'
      endIpAddress: '0.0.0.0'
    }
  }
}

output DbConnectionString string = 'Server=tcp:${sqlServer.name}${environment().suffixes.sqlServerHostname},1433;Initial Catalog=${name};User ID=${sqlServer.properties.administratorLogin};Password=${adminPassword}'
