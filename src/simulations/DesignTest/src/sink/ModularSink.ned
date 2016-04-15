//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

package designtest.sink;

import designtest.ParallelChannel;

module ModularSink like ISink
{
    parameters:
        double historyPollingInterval @unit(ns) = default(1ms);
    @display("bgb=587,344");
    gates:
        input data;
    submodules:
        dispatcherWrapper: DispatcherWrapper {
            @display("p=118,147");
        }
        configWrapper: ConfigWrapper {
            @display("p=255,65");
        }
        eventWrapper: EventWrapper {
            @display("p=255,147");
        }
        historicalQueueWrapper: HistoricalQueueWrapper {
            @display("p=255,234");
        }
        historyManagerWrapper: HistoryManagerWrapper {
            pollingInterval = historyPollingInterval;
            @display("p=462,234");
        }
    connections:
        dispatcherWrapper.config --> configWrapper.config;
        dispatcherWrapper.event --> eventWrapper.event;
        data --> dispatcherWrapper.data;
        dispatcherWrapper.historical --> ParallelChannel --> historicalQueueWrapper.historicalIn;
        historicalQueueWrapper.historicalOut --> historyManagerWrapper.historical;
        historyManagerWrapper.pollData --> historicalQueueWrapper.pollData;
}
