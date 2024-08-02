targetScope = 'subscription'

param environment 'dev' | 'stage' = 'dev'
@description('Should contain alphanumeric and \'-\' characters only ')
param projectName string
param location string = 'South Central US'

param sqlAdminUsername string = '${environment}-${projectName}'
@secure()
param sqlAdminPassword string

@secure()
param sendgridApiKey string = ''
param serverFarmName string = 'dev-elevator3-windows-plan'
param serverFarmResourceGroupName string = 'dev-elevator3-apps'
param netFrameworkVersion 'v6.0' | 'v8.0' = 'v6.0'

var resourceGroupName = '${environment}-${projectName}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}

module storageAccount 'blob-storage.bicep' = {
  name: 'storageModule'
  scope: resourceGroup
}

module sql 'sql.bicep' = {
  name: 'sqlModule'
  params: {
    adminUsername: sqlAdminUsername
    adminPassword: sqlAdminPassword
  }
  scope: resourceGroup
}

module appService 'app-service.bicep' = {
  name: 'appService'
  scope: resourceGroup
  params: {
    netFrameworkVersion: netFrameworkVersion
    sendgridApiKey: sendgridApiKey
    storageAccountName: storageAccount.outputs.storageAccountName
    sqlConnectionString: sql.outputs.DbConnectionString
    serverFarmName: serverFarmName
    serverFarmResourceGroupName: serverFarmResourceGroupName
  }
  dependsOn: [storageAccount, sql]
}
