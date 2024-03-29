import { gql } from 'graphql-request';

export const GET_ALL_DATA_SYNC_JOBS = gql`
  query {
    item(where: { path: "/sitecore/system/Modules/DataSync" }) {
      children {
        nodes {
          name
          itemId
          WebhookUrl: field(name: "WebhookUrl") {
            value
          }
          NewItemTemplate: field(name: "NewItemTemplate") {
            value
          }
          NewItemParent: field(name: "NewItemParent") {
            value
          }
          Language: field(name: "Language") {
            value
          }
          LastRun: field(name: "LastRun") {
            value
          }
          LastMessage: field(name: "LastMessage") {
            value
          }
        }
      }
    }
  }
`;
