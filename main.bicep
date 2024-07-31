targetScope = 'subscription'

param environment 'dev' | 'stage' = 'dev'

@description('Should contain alphanumeric and \'-\' characters only ')
param projectName string

param location string = 'South Central US'

var resourceGroupName = '${environment}-${projectName}'

param sqlAdminUsername string = '${environment}-${projectName}'
@secure()
param sqlAdminPassword string
@secure()
param sendgridApiKey string = ''

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
    sendgridApiKey: sendgridApiKey
    storageAccountName: storageAccount.outputs.storageAccountName
  }
  dependsOn: [storageAccount, sql]
}
