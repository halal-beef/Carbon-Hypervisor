/**
  Copyright (c) 2015 Samsung Electronics Co., Ltd.

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License version 2 as
  published by the Free Software Foundation.
**/

#include <generated/autoconf.h>

#ifndef _PMU_H_
#define _PMU_H_

//
// PMU Register Offsets
//
#define SWRESET                         0x0400
#define PS_HOLD_CONTROL                 0x330C

//
// PS_HOLD_CONTROL Register Bits
//
#define PS_HOLD_LOW                    (1 << 8)

#endif /* _PMU_H_ */
