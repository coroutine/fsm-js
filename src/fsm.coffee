class FSM
  @WILDCARD:                        "*"
  @VALID_NAME:                      /^[$A-Z_][0-9A-Z_$]*$/i
  @NO_NAME_ERROR:                   "An event must have a name."
  @BAD_NAME_ERROR:                  "'name' must be a valid variable name"
  @BAD_OPTIONS_ERROR:               "Please make sure 'options' specifies a transition from one state to another"
  @INITIAL_STATE_ERROR:             "The initial state is not a valid state."
  @INVALID_CALLBACK_POSITION_ERROR: "The specified callback position is invalid."
  @EVENT_EXISTS_ERROR:              "The specified event has already been defined."
  @EVENT_DOES_NOT_EXIST_ERROR:      "Cannot register a callback on a nonexistent event"
  
  events: []
  
  callbacks:
    before: {}
    after:  {}
  
  constructor: (options={}) ->
    throw FSM.INITIAL_STATE_ERROR unless _(options['states']).contains(options['initialState'])
    
    @currentState = options['initialState']
    @states       = options['states']
    
  state: -> @currentState
    
  event: (name, options) ->
    throw FSM.NO_NAME_ERROR       unless name
    throw FSM.BAD_NAME_ERROR      unless name.match(FSM.VALID_NAME)
    throw FSM.BAD_OPTIONS_ERROR   unless @eventOptionsAreValid(options)
    throw FSM.EVENT_EXISTS_ERROR  if _(@events).contains(name)
    
    transition  = options['transition']
    from        = if transition['from'] == FSM.WILDCARD then @states else _([transition['from']]).flatten()
    to          = transition['to']
    
    this[name] = =>
      throw "Cannot transition to #{to}, from #{@currentState}" unless _(from).contains(@currentState)
      
      @invokeCallbacks 'before', name
      @currentState = to
      @invokeCallbacks 'after', name
      return this
    
    @events.push name  
    return this
      
  before: (name, callback) ->
    @enqueueCallback 'before', name, callback
    
  after: (name, callback) ->
    @enqueueCallback 'after', name, callback
    
  enqueueCallback: (position, name, callback) ->
    throw FSM.INVALID_CALLBACK_POSITION_ERROR unless _(_(@callbacks).keys()).contains(position)
    throw FSM.EVENT_DOES_NOT_EXIST_ERROR      unless _(@events).contains(name) || name == FSM.WILDCARD
    
    if callback
      names       = if name == FSM.WILDCARD then @events else [name]
      collection  = @callbacks[position]
        
      _(names).each (evt) ->
        queue = (collection[evt] ||= [])
        queue.push callback
      
    return this
    
  invokeCallbacks: (position, name) ->
    _(@callbacks[position][name]).each (cb) -> cb()
      
  eventOptionsAreValid: (options) ->
    transition      = options?['transition']
    from            = transition?['from']
    fromIsWildcard  = from == FSM.WILDCARD
    fromStates      = _(_([transition?['from']]).flatten()).compact()
    fromHasElements = !!fromStates.length
    fromInStates    = _(@states).intersection(fromStates).length == fromStates.length
    to              = transition?['to']
    toIsString      = _(to).isString()
    toInStates      = _(@states).contains(to)
      
    !!(options                                              && 
      transition                                            && 
      (fromIsWildcard || (fromHasElements && fromInStates)) &&
      to                                                    &&
      toIsString                                            && 
      toInStates)
    