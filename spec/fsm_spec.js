// Generated by CoffeeScript 1.7.1
describe('FSM', function() {
  var fsm, initialState;
  initialState = 'asleep';
  fsm = new FSM({
    states: ['asleep', 'awake', 'standing', 'sitting', 'lying'],
    initialState: initialState
  });
  describe('#event', function() {
    var badNameError, badOptionsError, eventExistsError, noNameError;
    noNameError = FSM.NO_NAME_ERROR;
    badNameError = FSM.BAD_NAME_ERROR;
    badOptionsError = FSM.BAD_OPTIONS_ERROR;
    eventExistsError = FSM.EVENT_EXISTS_ERROR;
    it('should raise a no name error if no name is supplied', function() {
      return expect(function() {
        return fsm.event();
      }).toThrow(noNameError);
    });
    it('should raise a bad name error if the supplied name is not a valid variable name', function() {
      expect(function() {
        return fsm.event('23');
      }).toThrow(badNameError);
      return expect(function() {
        return fsm.event('space cadet');
      }).toThrow(badNameError);
    });
    it('should not raise a bad name error when the supplied name is a valid variable name', function() {
      expect(function() {
        return fsm.event('sleeperHold');
      }).not.toThrow(badNameError);
      expect(function() {
        return fsm.event('$makeMoney');
      }).not.toThrow(badNameError);
      return expect(function() {
        return fsm.event('_underscore_the_issue');
      }).not.toThrow(badNameError);
    });
    it('should raise a bad options error when no options are supplied', function() {
      return expect(function() {
        return fsm.event('foo');
      }).toThrow(badOptionsError);
    });
    it('should raise a bad options error when no :transition option is supplied', function() {
      return expect(function() {
        return fsm.event('bar', {});
      }).toThrow(badOptionsError);
    });
    it('should raise a bad options error when no :from transition is specified', function() {
      return expect(function() {
        return fsm.event('baz', {
          transition: {
            to: 'awake'
          }
        });
      }).toThrow(badOptionsError);
    });
    it('should raise a bad options error when no :to transition is specified', function() {
      return expect(function() {
        return fsm.event('qux', {
          transition: {
            from: 'asleep'
          }
        });
      }).toThrow(badOptionsError);
    });
    it('should raise a bad options error when :to is not a string', function() {
      return expect(function() {
        return fsm.event('zeb', {
          transition: {
            from: ['asleep', 'lying'],
            to: ['awake']
          }
        });
      }).toThrow(badOptionsError);
    });
    it('should raise a bad options error when :from is not a subset of the FSM states', function() {
      return expect(function() {
        return fsm.event('bob', {
          transition: {
            from: ['standing', 'floating'],
            to: 'lying'
          }
        });
      }).toThrow(badOptionsError);
    });
    it('should raise a bad options error when :to is not a valid FSM state', function() {
      return expect(function() {
        return fsm.event('buz', {
          transition: {
            from: ['asleep'],
            to: 'screaming'
          }
        });
      }).toThrow(badOptionsError);
    });
    it('should not raise an error with valid input', function() {
      expect(function() {
        return fsm.event('wap', {
          transition: {
            from: 'asleep',
            to: 'awake'
          }
        });
      }).not.toThrow();
      expect(function() {
        return fsm.event('zap', {
          transition: {
            from: ['standing', 'sitting'],
            to: 'asleep'
          }
        });
      }).not.toThrow();
      return expect(function() {
        return fsm.event('lob', {
          transition: {
            from: '*',
            to: 'asleep'
          }
        });
      }).not.toThrow();
    });
    it('should raise an error if the event has already been defined', function() {
      var defEvent;
      defEvent = function() {
        return fsm.event('party', {
          transition: {
            from: 'asleep',
            to: 'standing'
          }
        });
      };
      defEvent();
      return expect(defEvent).toThrow(eventExistsError);
    });
    return describe('event transitions', function() {
      fsm.event('slap', {
        transition: {
          from: 'asleep',
          to: 'awake'
        }
      });
      fsm.event('bludgeon', {
        transition: {
          from: ['standing', 'sitting'],
          to: 'lying'
        }
      });
      fsm.event('drug', {
        transition: {
          from: ['awake', 'standing', 'sitting', 'lying'],
          to: 'asleep'
        }
      });
      return describe('when in the initial state', function() {
        beforeEach(function() {
          return fsm.currentState = initialState;
        });
        it('should transition to awake when slapped', function() {
          fsm.slap();
          return expect(fsm.currentState).toBe('awake');
        });
        it('should raise an error when bludgeoned', function() {
          return expect(function() {
            return fsm.bludgeon();
          }).toThrow();
        });
        return it('should not change state when bludgeoned', function() {
          try {
            fsm.bludgeon();
          } catch (_error) {}
          return expect(fsm.currentState).toBe(initialState);
        });
      });
    });
  });
  describe('#before', function() {
    var noEventError;
    noEventError = FSM.EVENT_DOES_NOT_EXIST_ERROR;
    it('should raise a no event error when called for an undefined event', function() {
      return expect(function() {
        return fsm.before('grabIt', function() {});
      }).toThrow(noEventError);
    });
    it('should not raise an error when a callback is registered on an existing event', function() {
      fsm.event('flyToTheMoon', {
        transition: {
          from: ['sitting', 'lying'],
          to: 'standing'
        }
      });
      return expect(function() {
        return fsm.before('flyToTheMoon', function() {});
      }).not.toThrow();
    });
    it('should invoke the callback before the invocation of the event', function() {
      var listener;
      fsm.currentState = 'asleep';
      listener = {
        beforeEventCallback: function() {}
      };
      spyOn(listener, 'beforeEventCallback');
      fsm.event('digAHole', {
        transition: {
          from: 'asleep',
          to: 'awake'
        }
      }).before('digAHole', listener.beforeEventCallback).digAHole();
      return expect(listener.beforeEventCallback).toHaveBeenCalled();
    });
    return it('should register the callback for all events if the wildcard character is provided', function() {
      var listener;
      fsm.currentState = 'asleep';
      listener = {
        beforeEventCallback: function() {}
      };
      spyOn(listener, 'beforeEventCallback');
      fsm.event('rackTheBalls', {
        transition: {
          from: 'asleep',
          to: 'awake'
        }
      }).event('putOnPants', {
        transition: {
          from: ['awake', 'sitting', 'lying'],
          to: 'standing'
        }
      }).before('*', listener.beforeEventCallback).rackTheBalls().putOnPants();
      return expect(listener.beforeEventCallback.calls.length).toEqual(2);
    });
  });
  return describe('#after', function() {
    var noEventError;
    noEventError = FSM.EVENT_DOES_NOT_EXIST_ERROR;
    it('should raise a no event error when called for an undefined event', function() {
      return expect(function() {
        return fsm.before('dropIt', function() {});
      }).toThrow(noEventError);
    });
    it('should not raise an error when a callback is registered on an existing event', function() {
      fsm.event('flyToSaturn', {
        transition: {
          from: ['sitting', 'lying'],
          to: 'standing'
        }
      });
      return expect(function() {
        return fsm.before('flyToSaturn', function() {});
      }).not.toThrow();
    });
    it('should invoke the callback before the invocation of the event', function() {
      var listener;
      fsm.currentState = 'asleep';
      listener = {
        afterEventCallback: function() {}
      };
      spyOn(listener, 'afterEventCallback');
      fsm.event('buildAHouse', {
        transition: {
          from: 'asleep',
          to: 'awake'
        }
      }).before('buildAHouse', listener.afterEventCallback).buildAHouse();
      return expect(listener.afterEventCallback).toHaveBeenCalled();
    });
    return it('should register the callback for all events if the wildcard character is provided', function() {
      var listener;
      fsm.currentState = 'asleep';
      listener = {
        afterEventCallback: function() {}
      };
      spyOn(listener, 'afterEventCallback');
      fsm.event('rollTheDice', {
        transition: {
          from: 'asleep',
          to: 'awake'
        }
      }).event('stretch', {
        transition: {
          from: ['awake', 'sitting', 'lying'],
          to: 'standing'
        }
      }).before('*', listener.afterEventCallback).rollTheDice().stretch();
      return expect(listener.afterEventCallback.calls.length).toEqual(2);
    });
  });
});
