function [n, eventList] = PL_TrialEvents(s, waitForCode, waitTimeout);
%
%  PL_TrialEvents
%
%  n                     Number of events in eventList
%  eventList             Matrix n by 2, where (:, 1) is a timestamp, (:, 2) is a code
%
% Notes:
% 1) eventList is maintained as complete list, not segment that is cleared by each read.
% 2) Negative code means it is a strobe event with given value. For example, if code is -20973,
%    it was a strobe event (257) with value of 20973.
%
%  waitForCode           This event code, or the endTrialEventCode must occur before command is executed
%                        If zero, do not wait.
%  waitTimeout           Maximum amount of time to wait; will return after this many msecs (<=0 means wait indefinitely)
%
% Copyright (c) 2005 Plexon Inc
%
[n, eventList] = mexPlexOnline(14, s, waitForCode, waitTimeout);
