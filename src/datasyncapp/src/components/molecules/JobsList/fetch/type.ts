export type TJobQueryResult = {
  item: TItemResult;
};

export type TItemResult = {
  itemId: string;
  name: string;
  children?: TItemChildrenResult;
};

export type TItemChildrenResult = {
  nodes: TItemNodeResult[];
};

export type TItemNodeResult = {
  name: string;
  itemId: string;
  WebhookUrl: TItemFieldResult;

  NewItemTemplate: TItemFieldResult;
  NewItemParent: TItemFieldResult;
  Language: TItemFieldResult;

  LastRun: TItemFieldResult;
  LastMessage: TItemFieldResult;
};

export type TItemFieldResult = {
  value: string;
};
