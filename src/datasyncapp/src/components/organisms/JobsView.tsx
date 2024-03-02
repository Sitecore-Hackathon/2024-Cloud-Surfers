import { fetchDataSyncJobs, qKeyJobs } from '@/components/molecules/JobsList/fetch';
import { Container, Flex, FlexProps } from '@chakra-ui/react';
import { HydrationBoundary, QueryClient, dehydrate } from '@tanstack/react-query';
import { JobsList } from '../molecules/JobsList/JobsList';

export const JobsView = async (props: FlexProps) => {
  const queryClient = new QueryClient();

  // this will run server side
  await queryClient.prefetchQuery({
    queryKey: [qKeyJobs],
    queryFn: () => fetchDataSyncJobs(),
  });

  return (
    <HydrationBoundary state={dehydrate(queryClient)}>
      <Flex as="main" role="main" direction="column" flex="1" py="16" {...props}>
        <Container flex="1">
          <JobsList />
        </Container>
      </Flex>
    </HydrationBoundary>
  );
};
