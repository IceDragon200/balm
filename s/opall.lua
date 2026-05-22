local Object = require("balm/object")
--- @namespace balm.s

--- Nodes should not be stored outside of the OPALL structure, any operation that returns a Node
--- should be considered "temporary", any subsequent calls to the OPALL may modify existing Nodes.
--- @volatile
--- @since "2026.5.22"
--- @class Node<T>
local Node = Object:extends("balm.s.Node")
do
  local ic = Node.instance_class

  --- @spec #initialize(data: T): void
  function ic:initialize(data)
    ic._super.initialize(self)

    --- @member weight: Number
    self.weight = 0

    --- @member data: T
    self.data = data

    --- @member next: Node | false
    self.next = false
  end

  --- @spec #last(): Node
  function ic:last()
    local tail = self
    while tail.next do
      tail = tail.next
    end
    return tail
  end
end

--- Ordered, Pooled and Linked-List.
--- A hyper specific data structure for very specific uses.
--- @since "2026.5.22"
--- @class OPALL<T>
local OPALL = Object:extends("balm.s.OPALL")
do
  local ic = OPALL.instance_class

  --- @spec #initialize(options?: Table): void
  function ic:initialize(options)
    options = options or {}
    ic._super.initialize(self)

    --- @member m_pool_index: Number
    self.m_pool_index = 0

    --- @member m_pool: Node[]
    self.m_pool = {}

    --- The maximum number of nodes that can be created
    --- @member m_max_size: Number | false
    self.m_max_size = options.max_size or false

    --- The effective size of the list.
    --- @member m_size: Number
    self.m_size = 0

    --- @member next: Node | false
    self.next = false
  end

  --- @spec #size(): Number
  function ic:size()
    return self.m_size
  end

  --- @spec #last(): Node | nil
  function ic:last()
    if self.next then
      local tail = self.next
      while tail.next do
        tail = tail.next
      end
      return tail
    end
    return nil
  end

  --- If you intend to recycle the pool immediately, dirty_clear is the function for you.
  --- It will only return the nodes to the pool, with their links intact.
  --- @spec #dirty_clear(): self
  function ic:dirty_clear()
    self.m_size = 0
    local head = self.next
    while head do
      self.m_pool_index = self.m_pool_index + 1
      self.m_pool[self.m_pool_index] = head
      head = head.next
    end
    self.next = false
    return self
  end

  --- @spec #clear(): self
  function ic:clear()
    self.m_size = 0
    local prev
    local head = self.next
    while head do
      self.m_pool_index = self.m_pool_index + 1
      self.m_pool[self.m_pool_index] = head
      prev = head
      head = head.next
      prev.data = false
      prev.next = false
    end
    self.next = false
    return self
  end

  --- Attempts to insert a new item to the list, returns nil if there is no available space.
  --- @spec #insert(item: T, weight: Number): Node | nil
  function ic:insert(data, weight)
    if self.m_max_size then
      if self.m_size >= self.m_max_size then
        return nil
      end
    end

    --- We should always get a node, or just nil if there are no available nodes
    --- But in this case, we shouldn't get nil, because of the check done above.
    local node = self:_next_available_node()

    node.weight = weight
    node.data = data
    node.next = false

    self:_do_insert(node)

    return node
  end

  --- @spec #_do_insert(node: Node): void
  function ic:_do_insert(node)
    self.m_size = self.m_size + 1
    if self.next then
      local head = self.next
      if node.weight < head.weight then
        self.next = node
        node.next = head
        return
      else
        local prev = self
        while head do
          if node.weight < head.weight then
            node.next = head
            prev.next = node
            return
          end
          prev = head
          head = head.next
        end
        prev.next = node
      end
    else
      self.next = node
    end
  end

  --- Returns the head of the list, note it will be returned as-is from the list, the node
  --- should not be held as the pool may erase its contents on subsequent function calls.
  --- @spec #shift(): Node | nil
  function ic:shift()
    if self.m_size > 0 then
      self.m_size = self.m_size - 1
      local node = self.next
      self.next = node.next
      node.next = false
      self.m_pool_index = self.m_pool_index + 1
      self.m_pool[self.m_pool_index] = node
      return node
    end
    return nil
  end

  --- @spec #pop_at(index: Number): Node | nil
  function ic:pop_at(index)
    if index > self.m_size then
      return nil
    end

    if self.next then
      if index < 0 then
        index = 1 + self.m_size + index
      end
      local i = 0
      local prev = self
      local head = self.next
      while head do
        i = i + 1
        if i == index then
          self.m_size = self.m_size - 1
          prev.next = head.next
          head.next = false
          self.m_pool_index = self.m_pool_index + 1
          self.m_pool[self.m_pool_index] = head
          return head
        end
        prev = head
        head = head.next
      end
    end
    return nil
  end

  --- @spec #_next_available_node(): Node | nil
  function ic:_next_available_node()
    if self.m_pool_index > 0 then
      local node = self.m_pool[self.m_pool_index]
      self.m_pool[self.m_pool_index] = nil
      self.m_pool_index = self.m_pool_index - 1
      return node
    end

    if self.m_max_size then
      if self.m_size >= self.m_max_size then
        return nil
      end
    end

    return Node:new()
  end
end

return OPALL
