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

#ifndef CONFIGURATIONMANAGER_H_
#define CONFIGURATIONMANAGER_H_

#include "Data.h"

class ConfigurationManager
{
        // C-Tor / D-Tor
    public:
        ConfigurationManager();
        virtual ~ConfigurationManager();

        // Methods
    public:
        void SetNewConfiguration(Data::Packet packet);
};

#endif /* CONFIGURATIONMANAGER_H_ */
