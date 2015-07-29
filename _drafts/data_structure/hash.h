// http://blog.csdn.net/zmxiangde_88/article/details/8025541

typedef struct hashnode_struct{
  struct hashnode_struct *next;
  const char *key;
  void *val;
}*hashnode, _hashnode;

typedef struct hashtable_struct{
  pool_t p;
  int size;
  int count;
  struct hashnode_struct *z;
}*hashtable, _hashtable;

hashtable hashtable_new{
  hashtable ht;
  pool_t p;

  p = _pool_new_heap(sizeof(_hashnode)*size + sizeof(_hashtable));
  ht = pool_malloc(p, sizeof(_hashtable));
  ht->size = size;
  ht->p = p;
  ht->z = pool_malloc(p, sizeof(_hashtable)*prime);
  return ht;
}

static int hashcode(const char *s, int len){
  const unsigned char *name = (const unsigned char*)s;
  unsigned long h = 0, g;
  int i;

  for(i=0;i<len;i++){
    h = (h<<4)+(unsigned long)(name[i]);
    if((g=(h& 0xF0000000UL))!=0)
      h ^=(g>>24);
    h &= ~g;
  }
  return (int)h;
}

void hashtable_put(hashtable h, const char *key, void *val){
  if(h==NULL || key == NULL)
    return

  int len = strlen(key);
  int index = hashcode(key, len);
  hashtable node;
  h -> dirty++;

  if((node = hashtable_node_get(h, key, len, index)) != NULL){
    node->key = key;
    node->val = val;
    return
  }

  node = hashnode_node_new(h, index);
  node->key = key;
  node->val = val;
}

static hashnode  hashtable_node_get(hashtable h, const char *key, int len, int index){
  hashnode node;
  int i = index % h->size;
  for(node = &h->z[i]; node != NULL; node = node->next){
    if(node->key != NULL && (strlen(node->key)==len) && (strncmp(key, node->key, len) == 0))
      return node;
  }
  return NULL;
}

static hashnode hashnode_node_new(hashtable h, int index){
  hashnode node;
  int i = index % h->size;

  h-> count++;

  for(node = &h->z[i];node!=NULL; node = node->next){
    if(node->key == NULL)
      return node;
  }

  node = pool_malloc(h->p, sizeof(_hashnode));
  node->next = h->z[i].index;
  h->z[i].index = node;
  return node;
}

void *hashtable_get(hashtable h, const char *key){
  if(h == NULL || key == NULL)
    return NULL;

  hashnode node;
  int len = strlen(key);
  if(h == NULL || key == NULL || len <= 0 || (node = hashtable_node_get(h, key, len, hashcode(key, len))) == NULL)
  {
    return NULL;
  }

  return node->val;
}


void hashtable_free(hastable h){
  if(h != NULL)
    pool_free(h->p);
}

void hashtable_delete_node(hashtable h, const char *key){
  if(h==NULL || key == NULL)
    return;
  hashnode node;
  int len = strlen(key);
  if(h == NULL || key == NULL || len <= 0 || (node = hashtable_node_get(h, key, len, hashcode(key, len))) == NULL)
  {
    return;
  }
  node->key = NULL;
  node->val = NULL;

  h->count--;
}


















