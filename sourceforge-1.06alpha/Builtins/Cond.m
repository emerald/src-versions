% 
% @(#)Condition.m	1.2  3/6/91
%
const Condition <- immutable object Condition builtin 0x1005
  % Conditions implement Hoare style condition semantics, with the following
  % exceptions:
  %     1.  There is no urgent queue, signalers are placed at the head of 
  %         the monitor entry queue, and thus successive signals are 
  %         rescheduled in LIFO order.
  const ConditionType <- typeobject ConditionType builtin 0x1605
  end ConditionType
  export function getSignature -> [result : Signature]
    result <- ConditionType
  end getSignature
  export operation create -> [result : ConditionType]
    result <- immutable object aCondition builtin 0x1405
      %
      % Each condition holds a (4 byte) pointer to the object that contains
      % it as well as a pointer to an squeue of blocked processes.  Claiming
      % that the object is a string works to generate the right template.
      %
      attached var myObject : String
      var waitingQueue : Integer
      
      initially
	primitive "CONDINIT" [] <- []
      end initially
    end aCondition
  end create
end Condition

export Condition to "Builtins"
