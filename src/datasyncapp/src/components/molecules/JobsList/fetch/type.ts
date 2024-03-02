export type TJobQueryResult = {
  item: TItemResult;
};

export type TItemResult = {
  itemId: string;
  name: string;
  children: TItemChildrenResult;
};

export type TItemChildrenResult = {
  nodes: TItemNodeResult[];
};

export type TItemNodeResult = {
  name: string;
  webhook: TItemFieldResult;
};

export type TItemFieldResult = {
  value: string;
};
