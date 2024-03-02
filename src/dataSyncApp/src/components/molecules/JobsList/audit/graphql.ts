import { gql } from 'graphql-request';

export const AUDIT_WEBHOOK = gql`
  mutation AuditWebhook($webhookItemId: ID, $lastRun: String, $lastMessage: String) {
    updateItem(
      input: {
        itemId: $webhookItemId
        fields: [{ name: "LastRun", value: $lastRun }, { name: "LastMessage", value: $lastMessage }]
      }
    ) {
      item {
        itemId
      }
    }
  }
`;
