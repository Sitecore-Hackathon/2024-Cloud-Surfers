'use client';
import { RunButton } from '@/components/atoms/RunButton';
import {
  ButtonGroup,
  FlexProps,
  Stack,
  Table,
  TableContainer,
  Tbody,
  Td,
  Th,
  Thead,
  Tr,
} from '@chakra-ui/react';
import { useQuery } from '@tanstack/react-query';
import { fetchDataSyncJobs, qKeyJobs } from './fetch';

export const JobsList = (props: FlexProps) => {
  const queryJobs = useQuery({
    queryKey: [qKeyJobs],
    queryFn: () => fetchDataSyncJobs(),
    enabled: true,
  });
  return (
    <Stack spacing="16">
      <TableContainer whiteSpace="normal">
        <Table>
          <Thead>
            <Tr>
              <Th>Job Name</Th>
              <Th>Last Run</Th>
              <Th>Run</Th>
            </Tr>
          </Thead>

          {queryJobs.isSuccess && queryJobs.data && (
            <Tbody>
              {queryJobs.data.item.children.nodes.map((j) => (
                <Tr key={`tr${j.itemId?.replace('{', '').replace('}', '').replaceAll('-', '')}`}>
                  <Td>{j.name}</Td>
                  <Td>{j.LastRun?.value || 'n/a'}</Td>
                  <Td>
                    <ButtonGroup variant="ghost" size="sm">
                      <RunButton webhook={j.WebhookUrl?.value} />
                      {/* <Tooltip label="Edit">
                        <IconButton
                          icon={
                            <Icon>
                              <path d={mdiPencilOutline} />
                            </Icon>
                          }
                          size="lg"
                          aria-label={'Edit'}
                        />
                      </Tooltip> */}
                    </ButtonGroup>
                  </Td>
                </Tr>
              ))}
            </Tbody>
          )}
        </Table>
      </TableContainer>
    </Stack>
  );
};
