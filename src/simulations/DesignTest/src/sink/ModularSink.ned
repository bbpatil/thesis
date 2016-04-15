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

module ModularSink like ISink
{
    @display("bgb=587,344");
    gates:
        input data;
        input pollingCmd;
    submodules:
        dispatcherWrapper: DispatcherWrapper {
            @display("p=119,76");
        }
        configWrapper: ConfigWrapper {
            @display("p=255,65");
        }
        eventWrapper: EventWrapper {
            @display("p=255,148");
        }
        historicalQueueWrapper: HistoricalQueueWrapper {
            @display("p=243,249");
        }
        historyManagerWrapper: HistoryManagerWrapper {
            @display("p=463,249");
        }
    connections:
        dispatcherWrapper.config --> configWrapper.config;
        dispatcherWrapper.event --> eventWrapper.event;
        data --> dispatcherWrapper.data;
        dispatcherWrapper.historical --> historicalQueueWrapper.historicalIn;
        historicalQueueWrapper.historicalOut --> historyManagerWrapper.historical;
        historyManagerWrapper.pollData --> historicalQueueWrapper.pollData;
        pollingCmd --> historyManagerWrapper.pollingCmd;
}
