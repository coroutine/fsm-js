describe 'FSM', ->
  initialState  = 'asleep'
  fsm = new FSM states: ['asleep', 'awake', 'standing', 'sitting', 'lying'], initialState: initialState
  
  describe '#event', ->
    noNameError       = FSM.NO_NAME_ERROR
    badNameError      = FSM.BAD_NAME_ERROR
    badOptionsError   = FSM.BAD_OPTIONS_ERROR
    eventExistsError  = FSM.EVENT_EXISTS_ERROR
    
    it 'should raise a no name error if no name is supplied', ->
      expect(-> fsm.event()).toThrow(noNameError)
      
    it 'should raise a bad name error if the supplied name is not a valid variable name', ->
      expect(-> fsm.event('23')).toThrow(badNameError)
      expect(-> fsm.event('space cadet')).toThrow(badNameError)
      
    it 'should not raise a bad name error when the supplied name is a valid variable name', ->
      expect(-> fsm.event('sleeperHold')).not.toThrow(badNameError)
      expect(-> fsm.event('$makeMoney')).not.toThrow(badNameError)
      expect(-> fsm.event('_underscore_the_issue')).not.toThrow(badNameError)
      
    it 'should raise a bad options error when no options are supplied', ->
      expect(-> fsm.event('foo')).toThrow(badOptionsError)
      
    it 'should raise a bad options error when no :transition option is supplied', ->
      expect(-> fsm.event('bar', {})).toThrow(badOptionsError)
      
    it 'should raise a bad options error when no :from transition is specified', ->
      expect(-> fsm.event('baz', { transition: { to: 'awake' } })).toThrow(badOptionsError)
      
    it 'should raise a bad options error when no :to transition is specified', ->
      expect(-> fsm.event('qux', { transition: { from: 'asleep'} })).toThrow(badOptionsError)
      
    it 'should raise a bad options error when :to is not a string', ->
      expect(-> fsm.event('zeb', { transition: { from: ['asleep', 'lying'], to: ['awake'] } })).toThrow(badOptionsError)
      
    it 'should raise a bad options error when :from is not a subset of the FSM states', ->
      expect(-> fsm.event('bob', { transition: { from: ['standing', 'floating'], to: 'lying' } })).toThrow(badOptionsError)
      
    it 'should raise a bad options error when :to is not a valid FSM state', ->
      expect(-> fsm.event('buz', { transition: { from: ['asleep'], to: 'screaming' } })).toThrow(badOptionsError)
      
    it 'should not raise an error with valid input', ->
      expect(-> fsm.event('wap', { transition: { from: 'asleep', to: 'awake' } })).not.toThrow()
      expect(-> fsm.event('zap', { transition: { from: ['standing', 'sitting'], to: 'asleep' } })).not.toThrow()
      expect(-> fsm.event('lob', { transition: { from: '*', to: 'asleep' } })).not.toThrow()
      
    it 'should raise an error if the event has already been defined', ->
      defEvent = -> fsm.event 'party', transition: { from: 'asleep', to: 'standing' }
      defEvent()
      expect(defEvent).toThrow(eventExistsError)
    
    describe 'event transitions', ->
      fsm.event 'slap',     transition: { from: 'asleep', to: 'awake' }
      fsm.event 'bludgeon', transition: { from: ['standing', 'sitting'], to: 'lying' } 
      fsm.event 'drug',     transition: { from: ['awake', 'standing', 'sitting', 'lying'], to: 'asleep' }
        
      describe 'when in the initial state', ->
        beforeEach ->
          fsm.currentState = initialState
          
        it 'should transition to awake when slapped', ->
          fsm.slap()
          expect(fsm.currentState).toBe('awake')
          
        it 'should raise an error when bludgeoned', ->
          expect(-> fsm.bludgeon()).toThrow()
          
        it 'should not change state when bludgeoned', ->
          try fsm.bludgeon()
          expect(fsm.currentState).toBe(initialState)
          
  describe '#before', ->
    noEventError = FSM.EVENT_DOES_NOT_EXIST_ERROR
    
    it 'should raise a no event error when called for an undefined event', ->
      expect(-> fsm.before('grabIt', ->)).toThrow(noEventError)
      
    it 'should not raise an error when a callback is registered on an existing event', ->
      fsm.event 'flyToTheMoon', transition: { from: ['sitting', 'lying'], to: 'standing' }
      expect(-> fsm.before('flyToTheMoon', ->)).not.toThrow()
      
    it 'should invoke the callback before the invocation of the event', ->
      fsm.currentState = 'asleep'
      
      listener = { beforeEventCallback: -> }
      spyOn listener, 'beforeEventCallback'
      
      fsm.event('digAHole', transition: { from: 'asleep', to: 'awake' })
         .before('digAHole', listener.beforeEventCallback)
         
         .digAHole()
         
      expect(listener.beforeEventCallback).toHaveBeenCalled()
      
    it 'should register the callback for all events if the wildcard character is provided', ->
      fsm.currentState = 'asleep'
      
      listener = { beforeEventCallback: -> }
      spyOn listener, 'beforeEventCallback'
      
      fsm.event('rackTheBalls', transition: { from: 'asleep', to: 'awake' })
         .event('putOnPants',   transition: { from: ['awake', 'sitting', 'lying'], to: 'standing' })
         .before('*', listener.beforeEventCallback)
         
         .rackTheBalls()
         .putOnPants()
         
      expect(listener.beforeEventCallback.calls.length).toEqual(2)
  
  describe '#after', ->
    noEventError = FSM.EVENT_DOES_NOT_EXIST_ERROR
    
    it 'should raise a no event error when called for an undefined event', ->
      expect(-> fsm.before('dropIt', ->)).toThrow(noEventError)
      
    it 'should not raise an error when a callback is registered on an existing event', ->
      fsm.event 'flyToSaturn', transition: { from: ['sitting', 'lying'], to: 'standing' }
      expect(-> fsm.before('flyToSaturn', ->)).not.toThrow()
      
    it 'should invoke the callback before the invocation of the event', ->
      fsm.currentState = 'asleep'
      
      listener = { afterEventCallback: -> }
      spyOn listener, 'afterEventCallback'
      
      fsm.event('buildAHouse', transition: { from: 'asleep', to: 'awake' })
         .before('buildAHouse', listener.afterEventCallback)
         
         .buildAHouse()
         
      expect(listener.afterEventCallback).toHaveBeenCalled()
      
    it 'should register the callback for all events if the wildcard character is provided', ->
      fsm.currentState = 'asleep'
      
      listener = { afterEventCallback: -> }
      spyOn listener, 'afterEventCallback'
      
      fsm.event('rollTheDice',  transition: { from: 'asleep', to: 'awake' })
         .event('stretch',      transition: { from: ['awake', 'sitting', 'lying'], to: 'standing' })
         .before('*', listener.afterEventCallback)
         
         .rollTheDice()
         .stretch()
         
      expect(listener.afterEventCallback.calls.length).toEqual(2)
  