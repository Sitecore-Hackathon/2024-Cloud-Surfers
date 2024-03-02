import { gql } from "graphql-request";

export const GET_ALL_DATA_SYNC_JOBS = gql `
    query {
        item(path: "/sitecore/system/Modules/DataSync", language: "en") {
            children
            {
                name
            }
        }
    }
`