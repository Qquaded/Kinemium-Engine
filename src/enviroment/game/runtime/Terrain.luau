local Instance = require("@Instance")
local Color3 = require("@Color3")
local raylib = require("@raylib")
local r3d = require("@r3d")
local rlib = r3d.lib
local r3dstructs = r3d.structs
local meshgen = require("@meshgen")
local Vector3 = require("@Vector3")
local grassgen = require("../../classlibs/grassgen")

local EDGE_TABLE = {
	0x0,
	0x109,
	0x203,
	0x30a,
	0x406,
	0x50f,
	0x605,
	0x70c,
	0x80c,
	0x905,
	0xa0f,
	0xb06,
	0xc0a,
	0xd03,
	0xe09,
	0xf00,
	0x190,
	0x99,
	0x393,
	0x29a,
	0x596,
	0x49f,
	0x795,
	0x69c,
	0x99c,
	0x895,
	0xb9f,
	0xa96,
	0xd9a,
	0xc93,
	0xf99,
	0xe90,
	0x230,
	0x339,
	0x33,
	0x13a,
	0x636,
	0x73f,
	0x435,
	0x53c,
	0xa3c,
	0xb35,
	0x83f,
	0x936,
	0xe3a,
	0xf33,
	0xc39,
	0xd30,
	0x3a0,
	0x2a9,
	0x1a3,
	0xaa,
	0x7a6,
	0x6af,
	0x5a5,
	0x4ac,
	0xbac,
	0xaa5,
	0x9af,
	0x8a6,
	0xfaa,
	0xea3,
	0xda9,
	0xca0,
	0x460,
	0x569,
	0x663,
	0x76a,
	0x66,
	0x16f,
	0x265,
	0x36c,
	0xc6c,
	0xd65,
	0xe6f,
	0xf66,
	0x86a,
	0x963,
	0xa69,
	0xb60,
	0x5f0,
	0x4f9,
	0x7f3,
	0x6fa,
	0x1f6,
	0xff,
	0x3f5,
	0x2fc,
	0xdfc,
	0xcf5,
	0xfff,
	0xef6,
	0x9fa,
	0x8f3,
	0xbf9,
	0xaf0,
	0x650,
	0x759,
	0x453,
	0x55a,
	0x256,
	0x35f,
	0x55,
	0x15c,
	0xe5c,
	0xf55,
	0xc5f,
	0xd56,
	0xa5a,
	0xb53,
	0x859,
	0x950,
	0x7c0,
	0x6c9,
	0x5c3,
	0x4ca,
	0x3c6,
	0x2cf,
	0x1c5,
	0xcc,
	0xfcc,
	0xec5,
	0xdcf,
	0xcc6,
	0xbca,
	0xac3,
	0x9c9,
	0x8c0,
	0x8c0,
	0x9c9,
	0xac3,
	0xbca,
	0xcc6,
	0xdcf,
	0xec5,
	0xfcc,
	0xcc,
	0x1c5,
	0x2cf,
	0x3c6,
	0x4ca,
	0x5c3,
	0x6c9,
	0x7c0,
	0x950,
	0x859,
	0xb53,
	0xa5a,
	0xd56,
	0xc5f,
	0xf55,
	0xe5c,
	0x15c,
	0x55,
	0x35f,
	0x256,
	0x55a,
	0x453,
	0x759,
	0x650,
	0xaf0,
	0xbf9,
	0x8f3,
	0x9fa,
	0xef6,
	0xfff,
	0xcf5,
	0xdfc,
	0x2fc,
	0x3f5,
	0xff,
	0x1f6,
	0x6fa,
	0x7f3,
	0x4f9,
	0x5f0,
	0xb60,
	0xa69,
	0x963,
	0x86a,
	0xf66,
	0xe6f,
	0xd65,
	0xc6c,
	0x36c,
	0x265,
	0x16f,
	0x66,
	0x76a,
	0x663,
	0x569,
	0x460,
	0xca0,
	0xda9,
	0xea3,
	0xfaa,
	0x8a6,
	0x9af,
	0xaa5,
	0xbac,
	0x4ac,
	0x5a5,
	0x6af,
	0x7a6,
	0xaa,
	0x1a3,
	0x2a9,
	0x3a0,
	0xd30,
	0xc39,
	0xf33,
	0xe3a,
	0x936,
	0x83f,
	0xb35,
	0xa3c,
	0x53c,
	0x435,
	0x73f,
	0x636,
	0x13a,
	0x33,
	0x339,
	0x230,
	0xe90,
	0xf99,
	0xc93,
	0xd9a,
	0xa96,
	0xb9f,
	0x895,
	0x99c,
	0x69c,
	0x795,
	0x49f,
	0x596,
	0x29a,
	0x393,
	0x99,
	0x190,
	0xf00,
	0xe09,
	0xd03,
	0xc0a,
	0xb06,
	0xa0f,
	0x905,
	0x80c,
	0x70c,
	0x605,
	0x50f,
	0x406,
	0x30a,
	0x203,
	0x109,
	0x0,
}

local TRI_TABLE = {
	{},
	{ 0, 8, 3 },
	{ 0, 1, 9 },
	{ 1, 8, 3, 9, 8, 1 },
	{ 1, 2, 10 },
	{ 0, 8, 3, 1, 2, 10 },
	{ 9, 2, 10, 0, 2, 9 },
	{ 2, 8, 3, 2, 10, 8, 10, 9, 8 },
	{ 3, 11, 2 },
	{ 0, 11, 2, 8, 11, 0 },
	{ 1, 9, 0, 2, 3, 11 },
	{ 1, 11, 2, 1, 9, 11, 9, 8, 11 },
	{ 3, 10, 1, 11, 10, 3 },
	{ 0, 10, 1, 0, 8, 10, 8, 11, 10 },
	{ 3, 9, 0, 3, 11, 9, 11, 10, 9 },
	{ 9, 8, 10, 10, 8, 11 },
	{ 4, 7, 8 },
	{ 4, 3, 0, 7, 3, 4 },
	{ 0, 1, 9, 8, 4, 7 },
	{ 4, 1, 9, 4, 7, 1, 7, 3, 1 },
	{ 1, 2, 10, 8, 4, 7 },
	{ 3, 4, 7, 3, 0, 4, 1, 2, 10 },
	{ 9, 2, 10, 9, 0, 2, 8, 4, 7 },
	{ 2, 10, 9, 2, 9, 7, 2, 7, 3, 7, 9, 4 },
	{ 8, 4, 7, 3, 11, 2 },
	{ 11, 4, 7, 11, 2, 4, 2, 0, 4 },
	{ 9, 0, 1, 8, 4, 7, 2, 3, 11 },
	{ 4, 7, 11, 9, 4, 11, 9, 11, 2, 9, 2, 1 },
	{ 3, 10, 1, 3, 11, 10, 7, 8, 4 },
	{ 1, 11, 10, 1, 4, 11, 1, 0, 4, 7, 11, 4 },
	{ 4, 7, 8, 9, 0, 11, 9, 11, 10, 11, 0, 3 },
	{ 4, 7, 11, 4, 11, 9, 9, 11, 10 },
	{ 9, 5, 4 },
	{ 9, 5, 4, 0, 8, 3 },
	{ 0, 5, 4, 1, 5, 0 },
	{ 8, 5, 4, 8, 3, 5, 3, 1, 5 },
	{ 1, 2, 10, 9, 5, 4 },
	{ 3, 0, 8, 1, 2, 10, 4, 9, 5 },
	{ 5, 2, 10, 5, 4, 2, 4, 0, 2 },
	{ 2, 10, 5, 3, 2, 5, 3, 5, 4, 3, 4, 8 },
	{ 9, 5, 4, 2, 3, 11 },
	{ 0, 11, 2, 0, 8, 11, 4, 9, 5 },
	{ 0, 5, 4, 0, 1, 5, 2, 3, 11 },
	{ 2, 1, 5, 2, 5, 8, 2, 8, 11, 4, 8, 5 },
	{ 10, 3, 11, 10, 1, 3, 9, 5, 4 },
	{ 4, 9, 5, 0, 8, 1, 8, 10, 1, 8, 11, 10 },
	{ 5, 4, 0, 5, 0, 11, 5, 11, 10, 11, 0, 3 },
	{ 5, 4, 8, 5, 8, 10, 10, 8, 11 },
	{ 9, 7, 8, 5, 7, 9 },
	{ 9, 3, 0, 9, 5, 3, 5, 7, 3 },
	{ 0, 7, 8, 0, 1, 7, 1, 5, 7 },
	{ 1, 5, 3, 3, 5, 7 },
	{ 9, 7, 8, 9, 5, 7, 10, 1, 2 },
	{ 10, 1, 2, 9, 5, 0, 5, 3, 0, 5, 7, 3 },
	{ 8, 0, 2, 8, 2, 5, 8, 5, 7, 10, 5, 2 },
	{ 2, 10, 5, 2, 5, 3, 3, 5, 7 },
	{ 7, 9, 5, 7, 8, 9, 3, 11, 2 },
	{ 9, 5, 7, 9, 7, 2, 9, 2, 0, 2, 7, 11 },
	{ 2, 3, 11, 0, 1, 8, 1, 7, 8, 1, 5, 7 },
	{ 11, 2, 1, 11, 1, 7, 7, 1, 5 },
	{ 9, 5, 8, 8, 5, 7, 10, 1, 3, 10, 3, 11 },
	{ 5, 7, 0, 5, 0, 9, 7, 11, 0, 1, 0, 10, 11, 10, 0 },
	{ 11, 10, 0, 11, 0, 3, 10, 5, 0, 8, 0, 7, 5, 7, 0 },
	{ 11, 10, 5, 7, 11, 5 },
	{ 10, 6, 5 },
	{ 0, 8, 3, 5, 10, 6 },
	{ 9, 0, 1, 5, 10, 6 },
	{ 1, 8, 3, 1, 9, 8, 5, 10, 6 },
	{ 1, 6, 5, 2, 6, 1 },
	{ 1, 6, 5, 1, 2, 6, 3, 0, 8 },
	{ 9, 6, 5, 9, 0, 6, 0, 2, 6 },
	{ 5, 9, 8, 5, 8, 2, 5, 2, 6, 3, 2, 8 },
	{ 2, 3, 11, 10, 6, 5 },
	{ 11, 0, 8, 11, 2, 0, 10, 6, 5 },
	{ 0, 1, 9, 2, 3, 11, 5, 10, 6 },
	{ 5, 10, 6, 1, 9, 2, 9, 11, 2, 9, 8, 11 },
	{ 6, 3, 11, 6, 5, 3, 5, 1, 3 },
	{ 0, 8, 11, 0, 11, 5, 0, 5, 1, 5, 11, 6 },
	{ 3, 11, 6, 0, 3, 6, 0, 6, 5, 0, 5, 9 },
	{ 6, 5, 9, 6, 9, 11, 11, 9, 8 },
	{ 5, 10, 6, 4, 7, 8 },
	{ 4, 3, 0, 4, 7, 3, 6, 5, 10 },
	{ 1, 9, 0, 5, 10, 6, 8, 4, 7 },
	{ 10, 6, 5, 1, 9, 7, 1, 7, 3, 7, 9, 4 },
	{ 6, 1, 2, 6, 5, 1, 4, 7, 8 },
	{ 1, 2, 5, 5, 2, 6, 3, 0, 4, 3, 4, 7 },
	{ 8, 4, 7, 9, 0, 5, 0, 6, 5, 0, 2, 6 },
	{ 7, 3, 9, 7, 9, 4, 3, 2, 9, 5, 9, 6, 2, 6, 9 },
	{ 3, 11, 2, 7, 8, 4, 10, 6, 5 },
	{ 5, 10, 6, 4, 7, 2, 4, 2, 0, 2, 7, 11 },
	{ 0, 1, 9, 4, 7, 8, 2, 3, 11, 5, 10, 6 },
	{ 9, 2, 1, 9, 11, 2, 9, 4, 11, 7, 11, 4, 5, 10, 6 },
	{ 8, 4, 7, 3, 11, 5, 3, 5, 1, 5, 11, 6 },
	{ 5, 1, 11, 5, 11, 6, 1, 0, 11, 7, 11, 4, 0, 4, 11 },
	{ 0, 5, 9, 0, 6, 5, 0, 3, 6, 11, 6, 3, 8, 4, 7 },
	{ 6, 5, 9, 6, 9, 11, 4, 7, 9, 7, 11, 9 },
	{ 10, 4, 9, 6, 4, 10 },
	{ 4, 10, 6, 4, 9, 10, 0, 8, 3 },
	{ 10, 0, 1, 10, 6, 0, 6, 4, 0 },
	{ 8, 3, 1, 8, 1, 6, 8, 6, 4, 6, 1, 10 },
	{ 1, 4, 9, 1, 2, 4, 2, 6, 4 },
	{ 3, 0, 8, 1, 2, 9, 2, 4, 9, 2, 6, 4 },
	{ 0, 2, 4, 4, 2, 6 },
	{ 8, 3, 2, 8, 2, 4, 4, 2, 6 },
	{ 10, 4, 9, 10, 6, 4, 11, 2, 3 },
	{ 0, 8, 2, 2, 8, 11, 4, 9, 10, 4, 10, 6 },
	{ 3, 11, 2, 0, 1, 6, 0, 6, 4, 6, 1, 10 },
	{ 6, 4, 1, 6, 1, 10, 4, 8, 1, 2, 1, 11, 8, 11, 1 },
	{ 9, 6, 4, 9, 3, 6, 9, 1, 3, 11, 6, 3 },
	{ 8, 11, 1, 8, 1, 0, 11, 6, 1, 9, 1, 4, 6, 4, 1 },
	{ 3, 11, 6, 3, 6, 0, 0, 6, 4 },
	{ 6, 4, 8, 11, 6, 8 },
	{ 7, 10, 6, 7, 8, 10, 8, 9, 10 },
	{ 0, 7, 3, 0, 10, 7, 0, 9, 10, 6, 7, 10 },
	{ 10, 6, 7, 1, 10, 7, 1, 7, 8, 1, 8, 0 },
	{ 10, 6, 7, 10, 7, 1, 1, 7, 3 },
	{ 1, 2, 6, 1, 6, 8, 1, 8, 9, 8, 6, 7 },
	{ 2, 6, 9, 2, 9, 1, 6, 7, 9, 0, 9, 3, 7, 3, 9 },
	{ 7, 8, 0, 7, 0, 6, 6, 0, 2 },
	{ 7, 3, 2, 6, 7, 2 },
	{ 2, 3, 11, 10, 6, 8, 10, 8, 9, 8, 6, 7 },
	{ 2, 0, 7, 2, 7, 11, 0, 9, 7, 6, 7, 10, 9, 10, 7 },
	{ 1, 8, 0, 1, 7, 8, 1, 10, 7, 6, 7, 10, 2, 3, 11 },
	{ 11, 2, 1, 11, 1, 7, 10, 6, 1, 6, 7, 1 },
	{ 8, 9, 6, 8, 6, 7, 9, 1, 6, 11, 6, 3, 1, 3, 6 },
	{ 0, 9, 1, 11, 6, 7 },
	{ 7, 8, 0, 7, 0, 6, 3, 11, 0, 11, 6, 0 },
	{ 7, 11, 6 },
	{ 7, 6, 11 },
	{ 3, 0, 8, 11, 7, 6 },
	{ 0, 1, 9, 11, 7, 6 },
	{ 8, 1, 9, 8, 3, 1, 11, 7, 6 },
	{ 10, 1, 2, 6, 11, 7 },
	{ 1, 2, 10, 3, 0, 8, 6, 11, 7 },
	{ 2, 9, 0, 2, 10, 9, 6, 11, 7 },
	{ 6, 11, 7, 2, 10, 3, 10, 8, 3, 10, 9, 8 },
	{ 7, 2, 3, 6, 2, 7 },
	{ 7, 0, 8, 7, 6, 0, 6, 2, 0 },
	{ 2, 7, 6, 2, 3, 7, 0, 1, 9 },
	{ 1, 6, 2, 1, 8, 6, 1, 9, 8, 8, 7, 6 },
	{ 10, 7, 6, 10, 1, 7, 1, 3, 7 },
	{ 10, 7, 6, 1, 7, 10, 1, 8, 7, 1, 0, 8 },
	{ 0, 3, 7, 0, 7, 10, 0, 10, 9, 6, 10, 7 },
	{ 7, 6, 10, 7, 10, 8, 8, 10, 9 },
	{ 6, 8, 4, 11, 8, 6 },
	{ 3, 6, 11, 3, 0, 6, 0, 4, 6 },
	{ 8, 6, 11, 8, 4, 6, 9, 0, 1 },
	{ 9, 4, 6, 9, 6, 3, 9, 3, 1, 11, 3, 6 },
	{ 6, 8, 4, 6, 11, 8, 2, 10, 1 },
	{ 1, 2, 10, 3, 0, 11, 0, 6, 11, 0, 4, 6 },
	{ 4, 11, 8, 4, 6, 11, 0, 2, 9, 2, 10, 9 },
	{ 10, 9, 3, 10, 3, 2, 9, 4, 3, 11, 3, 6, 4, 6, 3 },
	{ 8, 2, 3, 8, 4, 2, 4, 6, 2 },
	{ 0, 4, 2, 4, 6, 2 },
	{ 1, 9, 0, 2, 3, 4, 2, 4, 6, 4, 3, 8 },
	{ 1, 9, 4, 1, 4, 2, 2, 4, 6 },
	{ 8, 1, 3, 8, 6, 1, 8, 4, 6, 6, 10, 1 },
	{ 10, 1, 0, 10, 0, 6, 6, 0, 4 },
	{ 4, 6, 3, 4, 3, 8, 6, 10, 3, 0, 3, 9, 10, 9, 3 },
	{ 10, 9, 4, 6, 10, 4 },
	{ 4, 9, 5, 7, 6, 11 },
	{ 0, 8, 3, 4, 9, 5, 11, 7, 6 },
	{ 5, 0, 1, 5, 4, 0, 7, 6, 11 },
	{ 11, 7, 6, 8, 3, 4, 3, 5, 4, 3, 1, 5 },
	{ 9, 5, 4, 10, 1, 2, 7, 6, 11 },
	{ 6, 11, 7, 1, 2, 10, 0, 8, 3, 4, 9, 5 },
	{ 7, 6, 11, 5, 4, 10, 4, 2, 10, 4, 0, 2 },
	{ 3, 4, 8, 3, 5, 4, 3, 2, 5, 10, 5, 2, 11, 7, 6 },
	{ 7, 2, 3, 7, 6, 2, 5, 4, 9 },
	{ 9, 5, 4, 0, 8, 6, 0, 6, 2, 6, 8, 7 },
	{ 3, 6, 2, 3, 7, 6, 1, 5, 0, 5, 4, 0 },
	{ 6, 2, 8, 6, 8, 7, 2, 1, 8, 4, 8, 5, 1, 5, 8 },
	{ 9, 5, 4, 10, 1, 6, 1, 7, 6, 1, 3, 7 },
	{ 1, 6, 10, 1, 7, 6, 1, 0, 7, 8, 7, 0, 9, 5, 4 },
	{ 4, 0, 10, 4, 10, 5, 0, 3, 10, 6, 10, 7, 3, 7, 10 },
	{ 7, 6, 10, 7, 10, 8, 5, 4, 10, 4, 8, 10 },
	{ 6, 9, 5, 6, 11, 9, 11, 8, 9 },
	{ 3, 6, 11, 0, 6, 3, 0, 5, 6, 0, 9, 5 },
	{ 0, 11, 8, 0, 5, 11, 0, 1, 5, 5, 6, 11 },
	{ 6, 11, 3, 6, 3, 5, 5, 3, 1 },
	{ 1, 2, 10, 9, 5, 11, 9, 11, 8, 11, 5, 6 },
	{ 0, 11, 3, 0, 6, 11, 0, 9, 6, 5, 6, 9, 1, 2, 10 },
	{ 11, 8, 5, 11, 5, 6, 8, 0, 5, 10, 5, 2, 0, 2, 5 },
	{ 6, 11, 3, 6, 3, 5, 2, 10, 3, 10, 5, 3 },
	{ 5, 8, 9, 5, 2, 8, 5, 6, 2, 3, 8, 2 },
	{ 9, 5, 6, 9, 6, 0, 0, 6, 2 },
	{ 1, 5, 8, 1, 8, 0, 5, 6, 8, 3, 8, 2, 6, 2, 8 },
	{ 1, 5, 6, 2, 1, 6 },
	{ 1, 3, 6, 1, 6, 10, 3, 8, 6, 5, 6, 9, 8, 9, 6 },
	{ 10, 1, 0, 10, 0, 6, 9, 5, 0, 5, 6, 0 },
	{ 0, 3, 8, 5, 6, 10 },
	{ 10, 5, 6 },
	{ 11, 5, 10, 7, 5, 11 },
	{ 11, 5, 10, 11, 7, 5, 8, 3, 0 },
	{ 5, 11, 7, 5, 10, 11, 1, 9, 0 },
	{ 10, 7, 5, 10, 11, 7, 9, 8, 1, 8, 3, 1 },
	{ 11, 1, 2, 11, 7, 1, 7, 5, 1 },
	{ 0, 8, 3, 1, 2, 7, 1, 7, 5, 7, 2, 11 },
	{ 9, 7, 5, 9, 2, 7, 9, 0, 2, 2, 11, 7 },
	{ 7, 5, 2, 7, 2, 11, 5, 9, 2, 3, 2, 8, 9, 8, 2 },
	{ 2, 5, 10, 2, 3, 5, 3, 7, 5 },
	{ 8, 2, 0, 8, 5, 2, 8, 7, 5, 10, 2, 5 },
	{ 9, 0, 1, 5, 10, 3, 5, 3, 7, 3, 10, 2 },
	{ 9, 8, 2, 9, 2, 1, 8, 7, 2, 10, 2, 5, 7, 5, 2 },
	{ 1, 3, 5, 3, 7, 5 },
	{ 0, 8, 7, 0, 7, 1, 1, 7, 5 },
	{ 9, 0, 3, 9, 3, 5, 5, 3, 7 },
	{ 9, 8, 7, 5, 9, 7 },
	{ 5, 8, 4, 5, 10, 8, 10, 11, 8 },
	{ 5, 0, 4, 5, 11, 0, 5, 10, 11, 11, 3, 0 },
	{ 0, 1, 9, 8, 4, 10, 8, 10, 11, 10, 4, 5 },
	{ 10, 11, 4, 10, 4, 5, 11, 3, 4, 9, 4, 1, 3, 1, 4 },
	{ 2, 5, 1, 2, 8, 5, 2, 11, 8, 4, 5, 8 },
	{ 0, 4, 11, 0, 11, 3, 4, 5, 11, 2, 11, 1, 5, 1, 11 },
	{ 0, 2, 5, 0, 5, 9, 2, 11, 5, 4, 5, 8, 11, 8, 5 },
	{ 9, 4, 5, 2, 11, 3 },
	{ 2, 5, 10, 3, 5, 2, 3, 4, 5, 3, 8, 4 },
	{ 5, 10, 2, 5, 2, 4, 4, 2, 0 },
	{ 3, 10, 2, 3, 5, 10, 3, 8, 5, 4, 5, 8, 0, 1, 9 },
	{ 5, 10, 2, 5, 2, 4, 1, 9, 2, 9, 4, 2 },
	{ 8, 4, 5, 8, 5, 3, 3, 5, 1 },
	{ 0, 4, 5, 1, 0, 5 },
	{ 8, 4, 5, 8, 5, 3, 9, 0, 5, 0, 3, 5 },
	{ 9, 4, 5 },
	{ 4, 11, 7, 4, 9, 11, 9, 10, 11 },
	{ 0, 8, 3, 4, 9, 7, 9, 11, 7, 9, 10, 11 },
	{ 1, 10, 11, 1, 11, 4, 1, 4, 0, 7, 4, 11 },
	{ 3, 1, 4, 3, 4, 8, 1, 10, 4, 7, 4, 11, 10, 11, 4 },
	{ 4, 11, 7, 9, 11, 4, 9, 2, 11, 9, 1, 2 },
	{ 9, 7, 4, 9, 11, 7, 9, 1, 11, 2, 11, 1, 0, 8, 3 },
	{ 11, 7, 4, 11, 4, 2, 2, 4, 0 },
	{ 11, 7, 4, 11, 4, 2, 8, 3, 4, 3, 2, 4 },
	{ 2, 9, 10, 2, 7, 9, 2, 3, 7, 7, 4, 9 },
	{ 9, 10, 7, 9, 7, 4, 10, 2, 7, 8, 7, 0, 2, 0, 7 },
	{ 3, 7, 10, 3, 10, 2, 7, 4, 10, 1, 10, 0, 4, 0, 10 },
	{ 1, 10, 2, 8, 7, 4 },
	{ 4, 9, 1, 4, 1, 7, 7, 1, 3 },
	{ 4, 9, 1, 4, 1, 7, 0, 8, 1, 8, 7, 1 },
	{ 4, 0, 3, 7, 4, 3 },
	{ 4, 8, 7 },
	{ 9, 10, 8, 10, 11, 8 },
	{ 3, 0, 9, 3, 9, 11, 11, 9, 10 },
	{ 0, 1, 10, 0, 10, 8, 8, 10, 11 },
	{ 3, 1, 10, 11, 3, 10 },
	{ 1, 2, 11, 1, 11, 9, 9, 11, 8 },
	{ 3, 0, 9, 3, 9, 11, 1, 2, 9, 2, 11, 9 },
	{ 0, 2, 11, 8, 0, 11 },
	{ 3, 2, 11 },
	{ 2, 3, 8, 2, 8, 10, 10, 8, 9 },
	{ 9, 10, 2, 0, 9, 2 },
	{ 2, 3, 8, 2, 8, 10, 0, 1, 8, 1, 10, 8 },
	{ 1, 10, 2 },
	{ 1, 3, 8, 9, 1, 8 },
	{ 0, 9, 1 },
	{ 0, 3, 8 },
	{},
}

local Terrain = Instance.new("Terrain")

local CHUNK_SIZE = 16 -- voxels per chunk axis
local UV_SCALE = 0.5 -- scale for planar UV mapping

local function chunkKey(cx, cy, cz)
	return cx .. "," .. cy .. "," .. cz
end

local function voxelToChunk(x, y, z)
	return math.floor(x / CHUNK_SIZE), math.floor(y / CHUNK_SIZE), math.floor(z / CHUNK_SIZE)
end

Terrain.InitRenderer = function(renderer, renderer_signal, datamodel)
	Terrain:SetProperties({
		Decoration = true,
		GrassLength = 10,
		BaseClass = "Singleton",
		MaterialColors = "",
		WaterColor = Color3.new(0, 0, 0),
		WaterReflectance = 0,
		WaterTransparency = 0,
		WaterWaveSize = 0,
		WaterWaveSpeed = 0,
		VoxelSize = 2,
		UseMarchingCubes = true,
		IsoLevel = 0.2,
		_blocks = {}, -- [x][y][z] = voxel
		_chunks = {}, -- chunkKey -> { mesh, dirty }
	})

	if FlagExists("server") then
		return Terrain
	end

	function Terrain:_getVoxel(x, y, z)
		local xr = Terrain._blocks[x]
		if not xr then
			return nil
		end
		local yr = xr[y]
		if not yr then
			return nil
		end
		return yr[z]
	end

	function Terrain:_getDensity(x, y, z)
		local xr = Terrain._blocks[x]
		if not xr then
			return 0
		end
		local yr = xr[y]
		if not yr then
			return 0
		end
		local v = yr[z]
		return v and v.density or 0
	end

	function Terrain:_getNormal(x, y, z)
		local nx = Terrain:_getDensity(x - 1, y, z) - Terrain:_getDensity(x + 1, y, z)
		local ny = Terrain:_getDensity(x, y - 1, z) - Terrain:_getDensity(x, y + 1, z)
		local nz = Terrain:_getDensity(x, y, z - 1) - Terrain:_getDensity(x, y, z + 1)

		local len = math.sqrt(nx * nx + ny * ny + nz * nz)
		if len < 1e-6 then
			return 0, 1, 0
		end
		return nx / len, ny / len, nz / len
	end

	function Terrain:_setVoxel(x, y, z, voxel)
		Terrain._blocks[x] = Terrain._blocks[x] or {}
		Terrain._blocks[x][y] = Terrain._blocks[x][y] or {}
		Terrain._blocks[x][y][z] = voxel

		local cx, cy, cz = voxelToChunk(x, y, z)
		local k = chunkKey(cx, cy, cz)
		if not Terrain._chunks[k] then
			Terrain._chunks[k] = { mesh = nil, dirty = true, cx = cx, cy = cy, cz = cz }
		else
			Terrain._chunks[k].dirty = true
		end
	end

	function Terrain:_interpolateVertex(p1, p2, v1, v2)
		local iso = Terrain.IsoLevel
		if math.abs(iso - v1) < 1e-5 then
			return p1
		end
		if math.abs(iso - v2) < 1e-5 then
			return p2
		end
		if math.abs(v2 - v1) < 1e-5 then
			return p1
		end
		local mu = (iso - v1) / (v2 - v1)
		return {
			p1[1] + mu * (p2[1] - p1[1]),
			p1[2] + mu * (p2[2] - p1[2]),
			p1[3] + mu * (p2[3] - p1[3]),
		}
	end

	function Terrain:_marchCube(x, y, z, vertices, indices)
		-- iodebug("Marching cube", x, y, z)
		local vs = Terrain.VoxelSize
		local px, py, pz = x * vs, y * vs, z * vs

		local corners = {
			{ px, py, pz },
			{ px + vs, py, pz },
			{ px + vs, py, pz + vs },
			{ px, py, pz + vs },
			{ px, py + vs, pz },
			{ px + vs, py + vs, pz },
			{ px + vs, py + vs, pz + vs },
			{ px, py + vs, pz + vs },
		}

		local values = {
			Terrain:_getDensity(x, y, z),
			Terrain:_getDensity(x + 1, y, z),
			Terrain:_getDensity(x + 1, y, z + 1),
			Terrain:_getDensity(x, y, z + 1),
			Terrain:_getDensity(x, y + 1, z),
			Terrain:_getDensity(x + 1, y + 1, z),
			Terrain:_getDensity(x + 1, y + 1, z + 1),
			Terrain:_getDensity(x, y + 1, z + 1),
		}

		local cubeIndex = 0
		for i = 1, 8 do
			if values[i] > Terrain.IsoLevel then
				cubeIndex = cubeIndex + bit32.lshift(1, i - 1)
			end
		end

		if cubeIndex == 0 or cubeIndex == 255 then
			return
		end

		local edges = {
			{ 1, 2 },
			{ 2, 3 },
			{ 3, 4 },
			{ 4, 1 },
			{ 5, 6 },
			{ 6, 7 },
			{ 7, 8 },
			{ 8, 5 },
			{ 1, 5 },
			{ 2, 6 },
			{ 3, 7 },
			{ 4, 8 },
		}
		local edgeFlag = EDGE_TABLE[cubeIndex + 1]
		local vertList = {}
		for i = 0, 11 do
			if bit32.band(edgeFlag, bit32.lshift(1, i)) ~= 0 then
				local e = edges[i + 1]
				vertList[i] = Terrain:_interpolateVertex(corners[e[1]], corners[e[2]], values[e[1]], values[e[2]])
			end
		end

		local triTable = TRI_TABLE[cubeIndex + 1]
		local baseIdx = #vertices -- zero-based index of next vertex

		local cornerNormals = {}
		for i = 1, 8 do
			local dx = (i == 2 or i == 3 or i == 6 or i == 7) and 1 or 0
			local dy = (i >= 5) and 1 or 0
			local dz = (i == 3 or i == 4 or i == 7 or i == 8) and 1 or 0
			local nx, ny, nz = Terrain:_getNormal(x + dx, y + dy, z + dz)
			cornerNormals[i] = { nx, ny, nz }
		end

		local function getInterpolatedNormal(vIdx)
			local e = edges[vIdx + 1]
			local n1, n2 = cornerNormals[e[1]], cornerNormals[e[2]]
			local v1, v2 = values[e[1]], values[e[2]]
			local mu = (Terrain.IsoLevel - v1) / (v2 - v1)
			local nx = n1[1] + mu * (n2[1] - n1[1])
			local ny = n1[2] + mu * (n2[2] - n1[2])
			local nz = n1[3] + mu * (n2[3] - n1[3])
			local len = math.sqrt(nx * nx + ny * ny + nz * nz)
			if len < 1e-6 then
				return { 0, 1, 0 }
			end
			return { nx / len, ny / len, nz / len }
		end

		for i = 1, #triTable, 3 do
			local vIdxA, vIdxB, vIdxC = triTable[i], triTable[i + 1], triTable[i + 2]
			local vA, vB, vC = vertList[vIdxA], vertList[vIdxB], vertList[vIdxC]

			if vA and vB and vC then
				local nA = getInterpolatedNormal(vIdxA)
				local nB = getInterpolatedNormal(vIdxB)
				local nC = getInterpolatedNormal(vIdxC)

				table.insert(vertices, {
					position = { vA[1], vA[2], vA[3] },
					color = { 255, 255, 255, 255 },
					uv = { vA[1] * UV_SCALE, vA[3] * UV_SCALE },
				})
				table.insert(vertices, {
					position = { vB[1], vB[2], vB[3] },
					color = { 255, 255, 255, 255 },
					uv = { vB[1] * UV_SCALE, vB[3] * UV_SCALE },
				})
				table.insert(vertices, {
					position = { vC[1], vC[2], vC[3] },
					color = { 255, 255, 255, 255 },
					uv = { vC[1] * UV_SCALE, vC[3] * UV_SCALE },
				})

				local b = #vertices - 3
				table.insert(indices, b)
				table.insert(indices, b + 1)
				table.insert(indices, b + 2)
			end
		end
	end

	local function addFaceVerts(vertices, indices, v1, v2, v3, v4, cr, cg, cb)
		local base = #vertices
		local col = { cr, cg, cb, 255 }
		table.insert(vertices, { position = v1, color = col })
		table.insert(vertices, { position = v2, color = col })
		table.insert(vertices, { position = v3, color = col })
		table.insert(vertices, { position = v4, color = col })
		table.insert(indices, base)
		table.insert(indices, base + 1)
		table.insert(indices, base + 2)
		table.insert(indices, base)
		table.insert(indices, base + 2)
		table.insert(indices, base + 3)
	end

	function Terrain:_rebuildChunk(chunk)
		local cx, cy, cz = chunk.cx, chunk.cy, chunk.cz
		local vs = Terrain.VoxelSize

		local x0 = cx * CHUNK_SIZE
		local y0 = cy * CHUNK_SIZE
		local z0 = cz * CHUNK_SIZE
		local x1 = x0 + CHUNK_SIZE - 1
		local y1 = y0 + CHUNK_SIZE - 1
		local z1 = z0 + CHUNK_SIZE - 1

		local vertices = table.create(4096)
		local indices = table.create(4096)

		if Terrain.UseMarchingCubes then
			for x = x0, x1 do
				for y = y0, y1 do
					for z = z0, z1 do
						Terrain:_marchCube(x, y, z, vertices, indices)
					end
				end
			end
		else
			local function isSolid(x, y, z)
				local v = Terrain:_getVoxel(x, y, z)
				return v and v.density > 0
			end

			for x = x0, x1 do
				local xr = Terrain._blocks[x]
				if xr then
					for y = y0, y1 do
						local yr = xr[y]
						if yr then
							for z = z0, z1 do
								local block = yr[z]
								if block and block.density > 0 then
									local col = block.color
									local cr, cg, cb = col.R * 255, col.G * 255, col.B * 255
									local px, py, pz = x * vs, y * vs, z * vs
									local s = vs

									local function V(dx, dy, dz)
										return { px + dx * s, py + dy * s, pz + dz * s }
									end

									if not isSolid(x + 1, y, z) then
										addFaceVerts(
											vertices,
											indices,
											V(1, 0, 0),
											V(1, 1, 0),
											V(1, 1, 1),
											V(1, 0, 1),
											cr,
											cg,
											cb
										)
									end
									if not isSolid(x - 1, y, z) then
										addFaceVerts(
											vertices,
											indices,
											V(0, 0, 1),
											V(0, 1, 1),
											V(0, 1, 0),
											V(0, 0, 0),
											cr,
											cg,
											cb
										)
									end
									if not isSolid(x, y + 1, z) then
										addFaceVerts(
											vertices,
											indices,
											V(0, 1, 1),
											V(1, 1, 1),
											V(1, 1, 0),
											V(0, 1, 0),
											cr,
											cg,
											cb
										)
									end
									if not isSolid(x, y - 1, z) then
										addFaceVerts(
											vertices,
											indices,
											V(0, 0, 0),
											V(1, 0, 0),
											V(1, 0, 1),
											V(0, 0, 1),
											cr,
											cg,
											cb
										)
									end
									if not isSolid(x, y, z + 1) then
										addFaceVerts(
											vertices,
											indices,
											V(1, 0, 1),
											V(1, 1, 1),
											V(0, 1, 1),
											V(0, 0, 1),
											cr,
											cg,
											cb
										)
									end
									if not isSolid(x, y, z - 1) then
										addFaceVerts(
											vertices,
											indices,
											V(0, 0, 0),
											V(0, 1, 0),
											V(1, 1, 0),
											V(1, 0, 0),
											cr,
											cg,
											cb
										)
									end
								end
							end
						end
					end
				end
			end
		end

		if #vertices == 0 then
			chunk.mesh = nil
			chunk.dominantMaterial = nil
			if chunk.grassInstanceBuffer then
				pcall(rlib.R3D_UnloadInstanceBuffer, chunk.grassInstanceBuffer)
				chunk.grassInstanceBuffer = nil
				chunk.grassInstanceCount = nil
			end
			chunk.dirty = false
			return
		end

		local matCounts = {}
		for x = x0, x1 do
			local xr = Terrain._blocks[x]
			if xr then
				for y = y0, y1 do
					local yr = xr[y]
					if yr then
						for z = z0, z1 do
							local v = yr[z]
							-- only count voxels that are actually solid and not air
							if v and (v.density or 0) >= Terrain.IsoLevel and v.material and v.material ~= "air" then
								matCounts[v.material] = (matCounts[v.material] or 0) + 1
							end
						end
					end
				end
			end
		end
		local bestMat, bestCount = "grass", 0
		for mat, count in pairs(matCounts) do
			if count > bestCount then
				bestMat, bestCount = mat, count
			end
		end
		chunk.dominantMaterial = bestMat

		local sv, si = meshgen.autoSmooth(vertices, indices, {
			angleThreshold = 90,
			tolerance = Terrain.VoxelSize * 0.05,
		})
		chunk.mesh = meshgen.buildMesh(sv, si, {
			indicesAreZeroBased = true,
			usage = meshgen.Usage.Dynamic,
		})
		chunk.dirty = false
		if Terrain.Decoration then
			Terrain:_spawnGrassForChunk(chunk)
		end
	end

	local MAX_REBUILDS_PER_FRAME = 4
	local MAX_CHUNK_DISTANCE = 12 -- chunks distance

	function Terrain:GenerateMesh()
		if Terrain._isGenerating then
			return
		end
		Terrain._isGenerating = true

		task.spawn(function()
			local count = 0
			local workspace = datamodel:GetService("Workspace")

			for _, chunk in pairs(Terrain._chunks) do
				if chunk.dirty then
					local camera = workspace.CurrentCamera
					local camPos = camera and camera.CFrame.Position or Vector3.new(0, 0, 0)

					local chunkWorldX = (chunk.cx + 0.5) * CHUNK_SIZE * Terrain.VoxelSize
					local chunkWorldY = (chunk.cy + 0.5) * CHUNK_SIZE * Terrain.VoxelSize
					local chunkWorldZ = (chunk.cz + 0.5) * CHUNK_SIZE * Terrain.VoxelSize

					local distSq = (chunkWorldX - camPos.X) ^ 2
						+ (chunkWorldY - camPos.Y) ^ 2
						+ (chunkWorldZ - camPos.Z) ^ 2
					local limitSq = (MAX_CHUNK_DISTANCE * CHUNK_SIZE * Terrain.VoxelSize) ^ 2

					if distSq <= limitSq then
						Terrain:_rebuildChunk(chunk)
						count = count + 1
						if count >= MAX_REBUILDS_PER_FRAME then
							count = 0
							task.wait()
						end
					end
				end
			end
			Terrain._isGenerating = false
		end)
	end

	function Terrain:_spawnGrassForChunk(chunk)
		if chunk.grassInstanceBuffer then
			pcall(rlib.R3D_UnloadInstanceBuffer, chunk.grassInstanceBuffer)
			chunk.grassInstanceBuffer = nil
			chunk.grassInstanceCount = nil
		end

		local cx, cy, cz = chunk.cx, chunk.cy, chunk.cz
		local x0 = cx * CHUNK_SIZE
		local y0 = cy * CHUNK_SIZE
		local z0 = cz * CHUNK_SIZE
		local vs = Terrain.VoxelSize

		local qw = grassgen.BLADE_QUAD_WIDTH -- rename to avoid collision with quaternion qw
		local ql = grassgen.BLADE_QUAD_LENGTH
		local instances = {}

		for x = x0, x0 + CHUNK_SIZE - 1 do
			for z = z0, z0 + CHUNK_SIZE - 1 do
				-- scan from 2 above the chunk top to catch surface voxels near the boundary
				for y = y0 + CHUNK_SIZE + 1, y0, -1 do
					local v = Terrain:_getVoxel(x, y, z)
					if not v or (v.density or 0) < Terrain.IsoLevel then
						continue -- air, keep scanning down
					end

					-- this voxel is solid, check the one above is air
					local above = Terrain:_getVoxel(x, y + 1, z)
					local aboveIsSolid = above and (above.density or 0) >= Terrain.IsoLevel
					if aboveIsSolid then
						break -- buried, nothing to spawn here
					end

					if v.material == "grass" then
						-- solid grass voxel with air above: spawn here
						local nx, ny, nz = Terrain:_getNormal(x, y, z)
						if ny >= 0.6 then
							local dBelow = Terrain:_getDensity(x, y, z)
							local dAbove = Terrain:_getDensity(x, y + 1, z)
							local surfaceFrac = 1.0
							if math.abs(dAbove - dBelow) > 1e-5 then
								surfaceFrac = math.max(0, math.min(1, (Terrain.IsoLevel - dBelow) / (dAbove - dBelow)))
							end

							local worldX = x * vs
							local worldY = (y + surfaceFrac) * vs
							local worldZ = z * vs

							local bladesPerVoxel = math.max(1, math.floor(Terrain.GrassLength * 4))
							for _ = 1, bladesPerVoxel do
								local angle = math.random() * math.pi * 2
								local rot_qy = math.sin(angle * 0.5)
								local rot_qw = math.cos(angle * 0.5)

								local ox = (math.random() - 0.5) * vs
								local oz = (math.random() - 0.5) * vs

								local sx = worldX + ox
								local sy = worldY
								local sz = worldZ + oz

								local bladeH = 0.4 + math.random()

								local vr = math.clamp(math.floor(46 + math.random() * 40), 0, 255)
								local vg = math.clamp(math.floor(140 + math.random() * 60), 0, 255)
								local vb = math.clamp(math.floor(28 + math.random() * 35), 0, 255)

								instances[#instances + 1] = {
									px = sx,
									py = worldY + bladeH * 0.5,
									pz = sz,
									qx = 0,
									qy = rot_qy,
									qz = 0,
									qw = rot_qw,
									sx = 1,
									sy = bladeH,
									sz = 1,
									r = vr,
									g = vg,
									b = vb,
									a = 255,
								}
							end
						end
					end
					break -- found the surface column, move on
				end
			end
		end

		if #instances == 0 then
			return
		end

		local buf, n = grassgen.createGrassInstanceBuffer(rlib, instances)
		chunk.grassInstanceBuffer = buf
		chunk.grassInstanceCount = n
	end

	function Terrain:FillBlock(minPos, maxPos, block)
		for x = minPos.X, maxPos.X do
			for y = minPos.Y, maxPos.Y do
				for z = minPos.Z, maxPos.Z do
					Terrain:_setVoxel(x, y, z, {
						density = block.density,
						material = block.material,
						color = block.color,
					})
				end
			end
		end
		Terrain:GenerateMesh()
	end

	function Terrain:Fill(posX, posY, posZ, width, height, options)
		posX = posX or 0
		posY = posY or 0
		posZ = posZ or 0
		width = width or 20
		height = height or 20
		options = options or {}
		local doMountains = options.mountains == true
		if Terrain.UseMarchingCubes then
			local function fade(t)
				return t * t * t * (t * (t * 6 - 15) + 10)
			end
			local function lerp(a, b, t)
				return a + t * (b - a)
			end
			local function hash(x, y, z)
				local n = math.sin(x * 127.1 + y * 311.7 + z * 74.3) * 43758.5453
				return n - math.floor(n)
			end
			local function valueNoise3(x, y, z)
				local ix, iy, iz = math.floor(x), math.floor(y), math.floor(z)
				local fx, fy, fz = x - ix, y - iy, z - iz
				local ux, uy, uz = fade(fx), fade(fy), fade(fz)
				local function h(a, b, c)
					return hash(a, b, c)
				end
				return lerp(
					lerp(
						lerp(h(ix, iy, iz), h(ix + 1, iy, iz), ux),
						lerp(h(ix, iy + 1, iz), h(ix + 1, iy + 1, iz), ux),
						uy
					),
					lerp(
						lerp(h(ix, iy, iz + 1), h(ix + 1, iy, iz + 1), ux),
						lerp(h(ix, iy + 1, iz + 1), h(ix + 1, iy + 1, iz + 1), ux),
						uy
					),
					uz
				)
			end
			local function fbm(x, y, z, oct, freq, amp)
				local v, a = 0, 0
				for _ = 1, oct do
					v = v + valueNoise3(x * freq, y * freq, z * freq) * amp
					a = a + amp
					freq = freq * 2.1
					amp = amp * 0.5
				end
				return v / a
			end

			-- mountain heightmap: large base hills + sharp ridges on top
			local function mountainHeight(x, z)
				-- broad base shape
				local base = fbm(x, 0, z, 5, 0.03, 1.0)
				-- ridge noise: take absolute value of noise then invert for sharp peaks
				local ridge1 = 1 - math.abs(fbm(x, 10, z, 4, 0.06, 1.0) * 2 - 1)
				local ridge2 = 1 - math.abs(fbm(x, 20, z, 3, 0.12, 1.0) * 2 - 1)
				ridge1 = ridge1 * ridge1 -- sharpen
				ridge2 = ridge2 * ridge2
				return base * 0.4 + ridge1 * 0.4 + ridge2 * 0.2
			end

			-- fill voxels
			local extraHeight = doMountains and height or 0
			for x = posX - width, posX + width do
				for z = posZ - width, posZ + width do
					local mh = 0
					if doMountains then
						mh = mountainHeight(x, z) * height * 1.4
					end

					local surfaceY = posY + height + mh

					for y = posY, posY + height * 2 + 10 do
						local depth = surfaceY - y

						-- base terrain density
						local sn = fbm(x, y, z, 4, 0.08, 1.0) * 4 - 2
						local density = math.max(0, math.min(1, depth / 5.0 + sn * 0.3))

						if density <= 0 then
							-- above surface, skip
							Terrain:_setVoxel(x, y, z, { density = 0, material = "air", color = Color3.new(1, 1, 1) })
						else
							local material, color
							if depth > 12 then
								material = "concrete"
								color = Color3.new(0.6, 0.6, 0.6)
							elseif depth > 4 then
								material = "dirt"
								color = Color3.new(0.52, 0.35, 0.18)
							elseif depth > 2 and doMountains and mh > height * 0.6 then
								material = "snow"
								color = Color3.new(0.95, 0.95, 1.0)
							elseif depth > 2 and doMountains and mh > height * 0.3 then
								material = "stone"
								color = Color3.new(0.55, 0.52, 0.48)
							else
								material = "grass"
								color = Color3.new(0.18, 0.72, 0.12)
							end

							Terrain:_setVoxel(x, y, z, { density = density, material = material, color = color })
						end
					end
				end
			end

			local function carveSphere(cx, cy, cz, radius)
				local ri = math.ceil(radius)
				for dx = -ri, ri do
					for dy = -ri, ri do
						for dz = -ri, ri do
							if dx * dx + dy * dy + dz * dz <= radius * radius then
								local wx, wy, wz = cx + dx, cy + dy, cz + dz
								if
									wx >= posX - width
									and wx <= posX + width
									and wz >= posZ - width
									and wz <= posZ + width
									and wy >= posY
								then
									local existing = Terrain:_getVoxel(wx, wy, wz)
									if existing and existing.material ~= "air" then
										local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
										local t = dist / radius
										local newDensity = existing.density * math.max(0, t * t - 0.1)
										Terrain:_setVoxel(wx, wy, wz, {
											density = newDensity,
											material = existing.material,
											color = existing.color,
										})
									end
								end
							end
						end
					end
				end
			end

			local function walkCave(startX, startY, startZ, seed)
				local rng = seed
				local function rand()
					rng = (rng * 1664525 + 1013904223) % (2 ^ 32)
					return rng / (2 ^ 32)
				end

				local angle = rand() * math.pi * 2
				local pitch = -0.4 - rand() * 0.3
				local radius = 2.5 + rand() * 1.5

				local px, py, pz = startX, startY, startZ
				local steps = 80 + math.floor(rand() * 120)

				for step = 1, steps do
					local t = step * 0.07
					angle = angle + (valueNoise3(px * 0.05, t, seed * 0.01) - 0.5) * 0.4
					pitch = pitch + (valueNoise3(t, py * 0.05, seed * 0.01 + 5) - 0.5) * 0.2
					pitch = math.max(-0.7, math.min(0.15, pitch))

					local dx = math.cos(pitch) * math.cos(angle)
					local dy = math.sin(pitch)
					local dz = math.cos(pitch) * math.sin(angle)

					local r = radius + math.sin(step * 0.3) * 0.8
					carveSphere(math.floor(px + 0.5), math.floor(py + 0.5), math.floor(pz + 0.5), r)

					px = px + dx
					py = py + dy
					pz = pz + dz

					if
						px < posX - width
						or px > posX + width
						or pz < posZ - width
						or pz > posZ + width
						or py < posY
					then
						break
					end
				end
			end

			local numCaves = math.max(1, math.floor((width * 2) / 12))
			for i = 1, numCaves do
				local ex = posX - width + math.random(0, width * 2)
				local ez = posZ - width + math.random(0, width * 2)

				local surfaceY = nil
				for y = posY + height * 2 + 10, posY, -1 do
					local v = Terrain:_getVoxel(ex, y, ez)
					if v and (v.density or 0) >= Terrain.IsoLevel then
						surfaceY = y
						break
					end
				end

				if surfaceY then
					walkCave(ex, surfaceY, ez, i * 9301 + 49297)
				end
			end
		else
			for x = posX - width, posX + width do
				for z = posZ - width, posZ + width do
					for y = posY, posY + height do
						local mat = math.random() > 0.5 and "Grass" or "water"
						local col = mat == "Grass" and Color3.new(0, 1, 0) or Color3.new(0, 0.235, 1)
						Terrain:_setVoxel(x, y, z, { density = 1, material = mat, color = col })
					end
				end
			end
		end
		Terrain:GenerateMesh()
	end

	function Terrain:StartRendering()
		local grassMat = grassgen.getGrassMaterial()
		local quadMesh = grassgen.getBladeQuadMesh()
		local grassShader = grassgen.getGrassSurfaceShader()

		local workspace = datamodel:GetService("Workspace")
		local terrainMatCache = {}

		local function getTerrainMaterial(materialName)
			if terrainMatCache[materialName] then
				return terrainMatCache[materialName]
			end
			local mat = workspace.loadMaterial(materialName)
			if mat then
				terrainMatCache[materialName] = mat
			end
			return mat
		end

		local identity = raylib.lib.MatrixIdentity()
		local grassWindBuf = buffer.create(4)
		buffer.writef32(grassWindBuf, 0, 0.08)
		local grassTimeBuf = buffer.create(4)

		renderer.Pool.new("3d", function()
			for _, chunk in pairs(Terrain._chunks) do
				if chunk.mesh then
					local matName = chunk.dominantMaterial or "grass"
					local mat = getTerrainMaterial(matName)
					if not mat then
						mat = getTerrainMaterial("grass") -- fallback
					end
					if mat and renderer.MeshPool then
						renderer.MeshPool.DrawMesh(chunk.mesh, mat.material, identity, nil, nil)
					end
				end

				if
					chunk.grassInstanceBuffer
					and chunk.grassInstanceCount
					and chunk.grassInstanceCount > 0
					and renderer.MeshPool
					and renderer.MeshPool.DrawMeshInstanced
				then
					buffer.writef32(grassTimeBuf, 0, raylib.lib.GetTime())
					rlib.R3D_SetSurfaceShaderUniform(grassShader, "u_windStrength", grassWindBuf)
					rlib.R3D_SetSurfaceShaderUniform(grassShader, "u_time", grassTimeBuf)

					renderer.MeshPool.DrawMeshInstanced(
						quadMesh,
						grassMat,
						chunk.grassInstanceBuffer,
						chunk.grassInstanceCount,
						nil,
						nil
					)
				end
			end
		end)
	end

	Terrain:StartRendering()

	return Terrain
end

return Terrain
