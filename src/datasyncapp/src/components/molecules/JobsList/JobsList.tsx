'use client';
import {
  ButtonGroup,
  FlexProps,
  Icon,
  IconButton,
  Stack,
  Table,
  TableContainer,
  Tbody,
  Td,
  Th,
  Thead,
  Tooltip,
  Tr,
} from '@chakra-ui/react';
import { mdiPencilOutline, mdiPlayOutline } from '@mdi/js';
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
                <Tr key={j.name}>
                  <Td>{j.name}</Td>
                  <Td>{j.webhook?.value}</Td>
                  <Td>
                    <ButtonGroup variant="ghost" size="sm">
                      <Tooltip label="Run!">
                        <IconButton
                          icon={
                            <Icon>
                              <path d={mdiPlayOutline} />
                            </Icon>
                          }
                          size="lg"
                          isActive
                          colorScheme="success"
                          aria-label={'Run'}
                        />
                      </Tooltip>
                      <Tooltip label="Edit">
                        <IconButton
                          icon={
                            <Icon>
                              <path d={mdiPencilOutline} />
                            </Icon>
                          }
                          size="lg"
                          aria-label={'Edit'}
                        />
                      </Tooltip>
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
