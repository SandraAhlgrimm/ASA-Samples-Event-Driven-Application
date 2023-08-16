param location string
param asaInstanceName string
param appName string
param tags object = {}
param relativePath string
param appInsightName string
param laWorkspaceResourceId string
param environmentVariables object = {}

resource asaInstance 'Microsoft.AppPlatform/Spring@2022-12-01' = {
  name: asaInstanceName
  location: location
  tags: union(tags, { 'azd-service-name': appName })
  sku: {
    name: 'S0'
    tier: 'Standard'
  }
}

resource asaApp 'Microsoft.AppPlatform/Spring/apps@2022-12-01' = {
  name: appName
  location: location
  parent: asaInstance
  properties: {
  }
}

resource asaDeployment 'Microsoft.AppPlatform/Spring/apps/deployments@2022-12-01' = {
  name: 'default'
  parent: asaApp
  properties: {
    source: {
      type: 'Jar'
      relativePath: relativePath
      runtimeVersion: 'Java_17'
    }
    deploymentSettings: {
      resourceRequests: {
        cpu: '2'
        memory: '4Gi'
      }
      environmentVariables: environmentVariables
    }
  }
}

resource springAppsMonitoringSettings 'Microsoft.AppPlatform/Spring/monitoringSettings@2023-03-01-preview' = {
  name: 'default' // The only supported value is 'default'
  parent: asaInstance
  properties: {
    traceEnabled: true
    appInsightsInstrumentationKey: applicationInsights.properties.InstrumentationKey
  }
}

resource springAppsDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'monitoring'
  scope: asaInstance
  properties: {
    workspaceId: laWorkspaceResourceId
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 30
          enabled: false
        }
      }
    ]
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = if (!(empty(appInsightName))) {
  name: appInsightName
}

output name string = asaApp.name