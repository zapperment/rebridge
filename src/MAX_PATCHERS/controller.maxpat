{
    "patcher": {
        "fileversion": 1,
        "appversion": {
            "major": 9,
            "minor": 1,
            "revision": 4,
            "architecture": "x64",
            "modernui": 1
        },
        "classnamespace": "box",
        "rect": [ 380.0, 166.0, 1652.0, 1144.0 ],
        "openinpresentation": 1,
        "default_fontsize": 10.0,
        "default_fontname": "Ableton Sans Small",
        "gridonopen": 2,
        "gridsize": [ 10.0, 10.0 ],
        "gridsnaponopen": 2,
        "objectsnaponopen": 0,
        "style": "rnbodefault",
        "subpatcher_template": "zapperment_template",
        "boxes": [
            {
                "box": {
                    "id": "obj-47",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 620.0, 590.0, 87.0, 20.0 ],
                    "text": "parseHexColour"
                }
            },
            {
                "box": {
                    "id": "obj-52",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 380.0, 180.0, 29.5, 20.0 ],
                    "text": "127"
                }
            },
            {
                "box": {
                    "id": "obj-50",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 320.0, 180.0, 29.5, 20.0 ],
                    "text": "1"
                }
            },
            {
                "box": {
                    "id": "obj-48",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 3,
                    "outlettype": [ "bang", "bang", "" ],
                    "patching_rect": [ 320.0, 130.0, 103.0, 20.0 ],
                    "text": "select range toggle"
                }
            },
            {
                "box": {
                    "id": "obj-46",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "patching_rect": [ 200.0, 240.0, 29.5, 20.0 ],
                    "text": "* 0"
                }
            },
            {
                "box": {
                    "id": "obj-45",
                    "linecount": 2,
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 930.0, 838.0, 150.0, 30.0 ],
                    "text": "formatting options for connected live.dial object",
                    "textcolor": [ 0.0, 0.5898008943, 1.0, 1.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-30",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 920.0, 868.0, 125.0, 20.0 ],
                    "text": "prepend activedialcolor"
                }
            },
            {
                "box": {
                    "annotation": "Connect inlet of live.dial object here",
                    "comment": "Connect inlet of live.dial object here",
                    "hint": "Connect inlet of live.dial object here",
                    "id": "obj-26",
                    "index": 0,
                    "maxclass": "outlet",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 640.0, 1008.0, 30.0, 30.0 ],
                    "varname": "dialOutput"
                }
            },
            {
                "box": {
                    "id": "obj-44",
                    "linecount": 5,
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 430.0, 598.0, 151.0, 67.0 ],
                    "text": "MIDI control change value (0-127) sent to the Live UI object, changes the object state and causes it to output the value",
                    "textcolor": [ 1.0, 0.5212053061, 1.0, 1.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-43",
                    "linecount": 2,
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 700.0, 838.0, 150.0, 30.0 ],
                    "text": "formatting options for connected live.slider object",
                    "textcolor": [ 0.9995340705, 0.988355577, 0.4726552367, 1.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-33",
                    "linecount": 2,
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 460.0, 838.0, 150.0, 30.0 ],
                    "text": "formatting options for connected live.button object",
                    "textcolor": [ 0.4513868093, 0.9930960536, 1.0, 1.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-27",
                    "linecount": 6,
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 1220.0, 708.0, 150.0, 79.0 ],
                    "text": "MIDI control change value (0-127) sent to the Live UI object — prefixed with \"set\" so as to change the object state, but not cause it to output the value",
                    "textcolor": [ 1.0, 0.4932718873, 0.4739984274, 1.0 ]
                }
            },
            {
                "box": {
                    "annotation": "Connect inlet of live.button object here",
                    "comment": "Connect inlet of live.button object here",
                    "hint": "Connect inlet of live.button object here",
                    "id": "obj-25",
                    "index": 0,
                    "maxclass": "outlet",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 530.0, 1008.0, 30.0, 30.0 ],
                    "varname": "buttonOutput"
                }
            },
            {
                "box": {
                    "id": "obj-41",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 960.0, 410.0, 29.5, 20.0 ],
                    "text": "2"
                }
            },
            {
                "box": {
                    "id": "obj-40",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 910.0, 410.0, 29.5, 20.0 ],
                    "text": "1"
                }
            },
            {
                "box": {
                    "id": "obj-34",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 860.0, 410.0, 29.5, 20.0 ],
                    "text": "0"
                }
            },
            {
                "box": {
                    "id": "obj-31",
                    "maxclass": "newobj",
                    "numinlets": 4,
                    "numoutlets": 4,
                    "outlettype": [ "bang", "bang", "bang", "" ],
                    "patching_rect": [ 860.0, 370.0, 119.0, 20.0 ],
                    "text": "select left center right"
                }
            },
            {
                "box": {
                    "id": "obj-17",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 900.0, 460.0, 102.0, 20.0 ],
                    "text": "textjustification $1"
                }
            },
            {
                "box": {
                    "id": "obj-29",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 451.0, 868.0, 132.0, 20.0 ],
                    "text": "prepend activebgoncolor"
                }
            },
            {
                "box": {
                    "id": "obj-19",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 740.0, 460.0, 153.0, 20.0 ],
                    "text": "presentation_rect 0. 0. $1 15."
                }
            },
            {
                "box": {
                    "id": "obj-24",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 90.0, 258.0, 29.5, 20.0 ],
                    "text": "127"
                }
            },
            {
                "box": {
                    "id": "obj-7",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": [ "", "" ],
                    "patching_rect": [ 90.0, 70.0, 62.0, 20.0 ],
                    "text": "route bang"
                }
            },
            {
                "box": {
                    "annotation": "Connect outlet of live.button object here",
                    "comment": "Connect outlet of live.button object here",
                    "hint": "Connect outlet of live.button object here",
                    "id": "obj-16",
                    "index": 0,
                    "maxclass": "inlet",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 90.0, 10.0, 30.0, 30.0 ]
                }
            },
            {
                "box": {
                    "annotation": "Connect live.slider objects here",
                    "comment": "Connect live.slider objects here",
                    "hint": "Connect live.slider objects here",
                    "id": "obj-12",
                    "index": 0,
                    "maxclass": "outlet",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 420.0, 1008.0, 30.0, 30.0 ],
                    "varname": "sliderOutput"
                }
            },
            {
                "box": {
                    "id": "obj-11",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1210.0, 528.0, 38.0, 20.0 ],
                    "text": "set $1"
                }
            },
            {
                "box": {
                    "id": "obj-23",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 591.0, 868.0, 89.0, 20.0 ],
                    "text": "prepend tricolor"
                }
            },
            {
                "box": {
                    "id": "obj-22",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 691.0, 868.0, 102.0, 20.0 ],
                    "text": "prepend trioncolor"
                }
            },
            {
                "box": {
                    "id": "obj-20",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 5,
                    "outlettype": [ "", "", "", "", "" ],
                    "patching_rect": [ 620.0, 778.0, 68.0, 20.0 ],
                    "text": "trigger l l l l l"
                }
            },
            {
                "box": {
                    "id": "obj-9",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "float" ],
                    "patching_rect": [ 1480.0, 550.0, 37.0, 20.0 ],
                    "text": "/ 255."
                }
            },
            {
                "box": {
                    "id": "obj-42",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 801.0, 868.0, 105.0, 20.0 ],
                    "text": "prepend slidercolor"
                }
            },
            {
                "box": {
                    "id": "obj-39",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": [ "", "" ],
                    "patching_rect": [ 1480.0, 610.0, 48.0, 20.0 ],
                    "text": "zl group"
                }
            },
            {
                "box": {
                    "id": "obj-38",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1480.0, 510.0, 67.0, 20.0 ],
                    "text": "fromsymbol"
                }
            },
            {
                "box": {
                    "id": "obj-37",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": [ "", "" ],
                    "patching_rect": [ 1480.0, 470.0, 143.0, 20.0 ],
                    "text": "combine 0x hex @triggers 1"
                }
            },
            {
                "box": {
                    "id": "obj-36",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1530.0, 420.0, 26.0, 20.0 ],
                    "text": "iter"
                }
            },
            {
                "box": {
                    "id": "obj-35",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "bang", "" ],
                    "patching_rect": [ 1450.0, 380.0, 57.0, 20.0 ],
                    "text": "trigger b l"
                }
            },
            {
                "box": {
                    "id": "obj-32",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 5,
                    "outlettype": [ "", "", "", "", "" ],
                    "patching_rect": [ 1450.0, 340.0, 93.0, 20.0 ],
                    "saved_object_attributes": {
                        "legacyoutputorder": 0
                    },
                    "text": "regexp ([\\\\w]{2})"
                }
            },
            {
                "box": {
                    "id": "obj-28",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1210.0, 638.0, 38.0, 20.0 ],
                    "text": "set $1"
                }
            },
            {
                "box": {
                    "id": "obj-21",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "bang", "int" ],
                    "patching_rect": [ 1140.0, 288.0, 57.0, 20.0 ],
                    "text": "trigger b i"
                }
            },
            {
                "box": {
                    "id": "obj-15",
                    "maxclass": "number",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 1210.0, 598.0, 50.0, 20.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-3",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1110.0, 528.0, 31.0, 20.0 ],
                    "text": "gate"
                }
            },
            {
                "box": {
                    "id": "obj-5",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "patching_rect": [ 1160.0, 478.0, 29.5, 20.0 ],
                    "text": "== 0"
                }
            },
            {
                "box": {
                    "id": "obj-96",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 9,
                    "outlettype": [ "int", "int", "int", "int", "int", "int", "int", "int", "int" ],
                    "patching_rect": [ 1170.0, 230.0, 119.0, 20.0 ],
                    "text": "unpack 0 0 0 0 0 0 0 0 0"
                }
            },
            {
                "box": {
                    "id": "obj-95",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1170.0, 50.0, 199.0, 20.0 ],
                    "text": "match 240 127 127 127 127 0 nn nn 247"
                }
            },
            {
                "box": {
                    "id": "obj-4",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "patching_rect": [ 1170.0, 6.0, 44.0, 20.0 ],
                    "text": "sysexin"
                }
            },
            {
                "box": {
                    "id": "obj-2",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 4,
                    "outlettype": [ "bang", "bang", "bang", "int" ],
                    "patching_rect": [ 200.0, 308.0, 74.0, 20.0 ],
                    "text": "trigger b b b i"
                }
            },
            {
                "box": {
                    "id": "obj-67",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 170.0, 1028.0, 46.0, 20.0 ],
                    "text": "midiout"
                }
            },
            {
                "box": {
                    "id": "obj-110",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 130.0, 848.0, 32.0, 20.0 ],
                    "text": "set 2"
                }
            },
            {
                "box": {
                    "id": "obj-106",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 20.0, 848.0, 29.5, 20.0 ],
                    "text": "2"
                }
            },
            {
                "box": {
                    "id": "obj-104",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 3,
                    "outlettype": [ "bang", "int", "int" ],
                    "patching_rect": [ 20.0, 818.0, 78.0, 20.0 ],
                    "text": "live.thisdevice"
                }
            },
            {
                "box": {
                    "id": "obj-103",
                    "maxclass": "number",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "bang" ],
                    "parameter_enable": 0,
                    "parameter_mappable": 0,
                    "patching_rect": [ 104.0, 927.0, 50.0, 20.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-98",
                    "maxclass": "newobj",
                    "numinlets": 8,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 170.0, 978.0, 158.0, 20.0 ],
                    "text": "pack 240 127 127 127 0 0 0 247"
                }
            },
            {
                "box": {
                    "id": "obj-93",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "int", "int" ],
                    "patching_rect": [ 420.0, 428.0, 57.0, 20.0 ],
                    "text": "trigger i 1"
                }
            },
            {
                "box": {
                    "id": "obj-10",
                    "maxclass": "newobj",
                    "numinlets": 7,
                    "numoutlets": 7,
                    "outlettype": [ "", "", "", "", "", "", "" ],
                    "patching_rect": [ 550.0, 70.0, 227.0, 20.0 ],
                    "text": "route controller label colour width align type"
                }
            },
            {
                "box": {
                    "id": "obj-6",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 3,
                    "outlettype": [ "int", "int", "int" ],
                    "patching_rect": [ 370.0, 268.0, 40.0, 20.0 ],
                    "text": "ctlin"
                }
            },
            {
                "box": {
                    "id": "obj-18",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 420.0, 388.0, 31.0, 20.0 ],
                    "text": "gate"
                }
            },
            {
                "box": {
                    "id": "obj-13",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 660.0, 460.0, 68.0, 20.0 ],
                    "text": "prepend set"
                }
            },
            {
                "box": {
                    "fontsize": 7.0,
                    "id": "obj-14",
                    "maxclass": "live.comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 660.0, 530.0, 38.5, 15.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 0.0, 0.0, 40.0, 15.0 ],
                    "text": "A1",
                    "textjustification": 1
                }
            },
            {
                "box": {
                    "id": "obj-8",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "" ],
                    "patching_rect": [ 420.0, 30.0, 257.0, 20.0 ],
                    "text": "patcherargs @width 40 @align center @type range"
                }
            },
            {
                "box": {
                    "id": "obj-1",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "patching_rect": [ 420.0, 328.0, 29.5, 20.0 ],
                    "text": "== 0"
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "destination": [ "obj-18", 0 ],
                    "source": [ "obj-1", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 1 ],
                    "midpoints": [ 559.5, 308.2851569056511, 440.0, 308.2851569056511 ],
                    "order": 1,
                    "source": [ "obj-10", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-13", 0 ],
                    "midpoints": [ 594.1666666666666, 296.4140631556511, 669.5, 296.4140631556511 ],
                    "source": [ "obj-10", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-19", 0 ],
                    "midpoints": [ 663.5, 292.76953125, 749.5, 292.76953125 ],
                    "source": [ "obj-10", 3 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-31", 0 ],
                    "midpoints": [ 698.1666666666666, 243.0078125, 869.5, 243.0078125 ],
                    "source": [ "obj-10", 4 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-47", 0 ],
                    "source": [ "obj-10", 2 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-48", 0 ],
                    "midpoints": [ 732.8333333333334, 109.140625, 329.5, 109.140625 ],
                    "source": [ "obj-10", 5 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-5", 1 ],
                    "midpoints": [ 559.5, 327.93802554975264, 1180.0, 327.93802554975264 ],
                    "order": 0,
                    "source": [ "obj-10", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-98", 5 ],
                    "midpoints": [ 559.5, 485.391417222796, 278.7857142857143, 485.391417222796 ],
                    "order": 2,
                    "source": [ "obj-10", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-98", 4 ],
                    "midpoints": [ 113.5, 967.7539522051811, 258.92857142857144, 967.7539522051811 ],
                    "source": [ "obj-103", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-106", 0 ],
                    "source": [ "obj-104", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-103", 0 ],
                    "midpoints": [ 29.5, 902.08988904953, 113.5, 902.08988904953 ],
                    "source": [ "obj-106", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.4932718873, 0.4739984274, 1.0 ],
                    "destination": [ "obj-15", 0 ],
                    "source": [ "obj-11", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-103", 0 ],
                    "midpoints": [ 139.5, 886.6484834551811, 113.5, 886.6484834551811 ],
                    "source": [ "obj-110", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-14", 0 ],
                    "source": [ "obj-13", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.4932718873, 0.4739984274, 1.0 ],
                    "destination": [ "obj-28", 0 ],
                    "source": [ "obj-15", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-7", 0 ],
                    "source": [ "obj-16", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-14", 0 ],
                    "midpoints": [ 909.5, 504.8515625, 669.5, 504.8515625 ],
                    "source": [ "obj-17", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.5212053061, 1.0, 1.0 ],
                    "destination": [ "obj-93", 0 ],
                    "source": [ "obj-18", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-14", 0 ],
                    "midpoints": [ 749.5, 494.958984375, 669.5, 494.958984375 ],
                    "source": [ "obj-19", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-103", 0 ],
                    "midpoints": [ 246.16666666666666, 785.7539522051811, 113.5, 785.7539522051811 ],
                    "source": [ "obj-2", 2 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-110", 0 ],
                    "midpoints": [ 209.5, 807.6133272638544, 139.5, 807.6133272638544 ],
                    "source": [ "obj-2", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-98", 6 ],
                    "midpoints": [ 264.5, 866.9258272051811, 298.6428571428571, 866.9258272051811 ],
                    "source": [ "obj-2", 3 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-98", 0 ],
                    "midpoints": [ 227.83333333333334, 841.6562959551811, 179.5, 841.6562959551811 ],
                    "source": [ "obj-2", 1 ]
                }
            },
            {
                "patchline": {
                    "color": [ 0.9995340705, 0.988355577, 0.4726552367, 1.0 ],
                    "destination": [ "obj-22", 0 ],
                    "midpoints": [ 654.0, 830.2086783749983, 700.5, 830.2086783749983 ],
                    "source": [ "obj-20", 2 ]
                }
            },
            {
                "patchline": {
                    "color": [ 0.9995340705, 0.988355577, 0.4726552367, 1.0 ],
                    "destination": [ "obj-23", 0 ],
                    "midpoints": [ 641.75, 828.785214408068, 600.5, 828.785214408068 ],
                    "source": [ "obj-20", 1 ]
                }
            },
            {
                "patchline": {
                    "color": [ 0.4513868093, 0.9930960536, 1.0, 1.0 ],
                    "destination": [ "obj-29", 0 ],
                    "midpoints": [ 629.5, 817.296875, 460.5, 817.296875 ],
                    "source": [ "obj-20", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 0.0, 0.5898008943, 1.0, 1.0 ],
                    "destination": [ "obj-30", 0 ],
                    "midpoints": [ 678.5, 815.734375, 929.5, 815.734375 ],
                    "source": [ "obj-20", 4 ]
                }
            },
            {
                "patchline": {
                    "color": [ 0.9995340705, 0.988355577, 0.4726552367, 1.0 ],
                    "destination": [ "obj-42", 0 ],
                    "midpoints": [ 666.25, 826.5518104785588, 810.5, 826.5518104785588 ],
                    "source": [ "obj-20", 3 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-3", 1 ],
                    "midpoints": [ 1149.5, 462.74688079277985, 1131.5, 462.74688079277985 ],
                    "source": [ "obj-21", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-5", 0 ],
                    "midpoints": [ 1187.5, 325.7625037515536, 1169.5, 325.7625037515536 ],
                    "source": [ "obj-21", 1 ]
                }
            },
            {
                "patchline": {
                    "color": [ 0.9995340705, 0.988355577, 0.4726552367, 1.0 ],
                    "destination": [ "obj-12", 0 ],
                    "midpoints": [ 700.5, 927.1079538853373, 429.5, 927.1079538853373 ],
                    "source": [ "obj-22", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 0.9995340705, 0.988355577, 0.4726552367, 1.0 ],
                    "destination": [ "obj-12", 0 ],
                    "midpoints": [ 600.5, 918.8498766496778, 429.5, 918.8498766496778 ],
                    "source": [ "obj-23", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 0 ],
                    "midpoints": [ 99.5, 293.8515671447385, 209.5, 293.8515671447385 ],
                    "source": [ "obj-24", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.4932718873, 0.4739984274, 1.0 ],
                    "destination": [ "obj-12", 0 ],
                    "midpoints": [ 1219.5, 937.6997071134392, 429.5, 937.6997071134392 ],
                    "order": 2,
                    "source": [ "obj-28", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.4932718873, 0.4739984274, 1.0 ],
                    "destination": [ "obj-25", 0 ],
                    "midpoints": [ 1219.5, 949.3984375, 539.5, 949.3984375 ],
                    "order": 1,
                    "source": [ "obj-28", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.4932718873, 0.4739984274, 1.0 ],
                    "destination": [ "obj-26", 0 ],
                    "midpoints": [ 1219.5, 959.92578125, 649.5, 959.92578125 ],
                    "order": 0,
                    "source": [ "obj-28", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 0.4513868093, 0.9930960536, 1.0, 1.0 ],
                    "destination": [ "obj-25", 0 ],
                    "midpoints": [ 460.5, 911.654296875, 539.5, 911.654296875 ],
                    "source": [ "obj-29", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-15", 0 ],
                    "midpoints": [ 1119.5, 568.5937565634958, 1219.5, 568.5937565634958 ],
                    "source": [ "obj-3", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 0.0, 0.5898008943, 1.0, 1.0 ],
                    "destination": [ "obj-26", 0 ],
                    "midpoints": [ 929.5, 985.22265625, 649.5, 985.22265625 ],
                    "source": [ "obj-30", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-34", 0 ],
                    "source": [ "obj-31", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-40", 0 ],
                    "midpoints": [ 902.8333333333334, 398.966796875, 919.5, 398.966796875 ],
                    "source": [ "obj-31", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-41", 0 ],
                    "midpoints": [ 936.1666666666666, 399.490234375, 969.5, 399.490234375 ],
                    "source": [ "obj-31", 2 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-35", 0 ],
                    "midpoints": [ 1496.5, 366.75650660693645, 1459.5, 366.75650660693645 ],
                    "source": [ "obj-32", 2 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-17", 0 ],
                    "midpoints": [ 869.5, 445.91796875, 909.5, 445.91796875 ],
                    "source": [ "obj-34", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-36", 0 ],
                    "midpoints": [ 1497.5, 412.748693106696, 1539.5, 412.748693106696 ],
                    "source": [ "obj-35", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-39", 0 ],
                    "midpoints": [ 1459.5, 586.7317642273847, 1489.5, 586.7317642273847 ],
                    "source": [ "obj-35", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-37", 1 ],
                    "midpoints": [ 1539.5, 458.1067631661426, 1613.5, 458.1067631661426 ],
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-38", 0 ],
                    "source": [ "obj-37", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-9", 0 ],
                    "source": [ "obj-38", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-95", 0 ],
                    "source": [ "obj-4", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-17", 0 ],
                    "midpoints": [ 919.5, 449.814453125, 909.5, 449.814453125 ],
                    "source": [ "obj-40", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-17", 0 ],
                    "midpoints": [ 969.5, 449.66015625, 909.5, 449.66015625 ],
                    "source": [ "obj-41", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 0.9995340705, 0.988355577, 0.4726552367, 1.0 ],
                    "destination": [ "obj-12", 0 ],
                    "midpoints": [ 810.5, 968.3431952800602, 429.5, 968.3431952800602 ],
                    "source": [ "obj-42", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 0 ],
                    "source": [ "obj-46", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-20", 0 ],
                    "source": [ "obj-47", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-50", 0 ],
                    "source": [ "obj-48", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-52", 0 ],
                    "midpoints": [ 371.5, 165.25390625, 389.5, 165.25390625 ],
                    "source": [ "obj-48", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-3", 0 ],
                    "midpoints": [ 1169.5, 518.4375, 1119.5, 518.4375 ],
                    "source": [ "obj-5", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-46", 1 ],
                    "midpoints": [ 329.5, 211.69921875, 220.0, 211.69921875 ],
                    "source": [ "obj-50", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-46", 1 ],
                    "midpoints": [ 389.5, 223.10546875, 220.0, 223.10546875 ],
                    "source": [ "obj-52", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 0 ],
                    "midpoints": [ 390.0, 308.2656256556511, 429.5, 308.2656256556511 ],
                    "source": [ "obj-6", 1 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.5212053061, 1.0, 1.0 ],
                    "destination": [ "obj-18", 1 ],
                    "midpoints": [ 379.5, 362.4335944056511, 441.5, 362.4335944056511 ],
                    "source": [ "obj-6", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-24", 0 ],
                    "source": [ "obj-7", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-46", 0 ],
                    "midpoints": [ 142.5, 120.9765625, 209.5, 120.9765625 ],
                    "source": [ "obj-7", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-10", 0 ],
                    "midpoints": [ 667.5, 58.97461003065109, 559.5, 58.97461003065109 ],
                    "source": [ "obj-8", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-39", 0 ],
                    "source": [ "obj-9", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-103", 0 ],
                    "midpoints": [ 467.5, 467.1132819056511, 113.5, 467.1132819056511 ],
                    "source": [ "obj-93", 1 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.5212053061, 1.0, 1.0 ],
                    "destination": [ "obj-12", 0 ],
                    "order": 2,
                    "source": [ "obj-93", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.5212053061, 1.0, 1.0 ],
                    "destination": [ "obj-25", 0 ],
                    "midpoints": [ 429.5, 978.203125, 539.5, 978.203125 ],
                    "order": 1,
                    "source": [ "obj-93", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.5212053061, 1.0, 1.0 ],
                    "destination": [ "obj-26", 0 ],
                    "midpoints": [ 429.5, 987.22265625, 649.5, 987.22265625 ],
                    "order": 0,
                    "source": [ "obj-93", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-96", 0 ],
                    "source": [ "obj-95", 0 ]
                }
            },
            {
                "patchline": {
                    "color": [ 1.0, 0.4932718873, 0.4739984274, 1.0 ],
                    "destination": [ "obj-11", 0 ],
                    "midpoints": [ 1267.0, 419.34141280292533, 1219.5, 419.34141280292533 ],
                    "source": [ "obj-96", 7 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-21", 0 ],
                    "midpoints": [ 1254.5, 273.6062529743649, 1149.5, 273.6062529743649 ],
                    "source": [ "obj-96", 6 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-67", 0 ],
                    "source": [ "obj-98", 0 ]
                }
            }
        ],
        "autosave": 0,
        "styles": [
            {
                "name": "rnbodefault",
                "default": {
                    "accentcolor": [ 0.343034118413925, 0.506230533123016, 0.86220508813858, 1.0 ],
                    "bgcolor": [ 0.031372549019608, 0.125490196078431, 0.211764705882353, 1.0 ],
                    "bgfillcolor": {
                        "angle": 270.0,
                        "autogradient": 0.0,
                        "color": [ 0.031372549019608, 0.125490196078431, 0.211764705882353, 1.0 ],
                        "color1": [ 0.031372549019608, 0.125490196078431, 0.211764705882353, 1.0 ],
                        "color2": [ 0.263682, 0.004541, 0.038797, 1.0 ],
                        "proportion": 0.39,
                        "type": "color"
                    },
                    "color": [ 0.929412, 0.929412, 0.352941, 1.0 ],
                    "elementcolor": [ 0.357540726661682, 0.515565991401672, 0.861786782741547, 1.0 ],
                    "fontname": [ "Lato" ],
                    "fontsize": [ 12.0 ],
                    "stripecolor": [ 0.258338063955307, 0.352425158023834, 0.511919498443604, 1.0 ],
                    "textcolor_inverse": [ 0.968627, 0.968627, 0.968627, 1 ]
                },
                "parentstyle": "",
                "multi": 0
            },
            {
                "name": "rnbolight",
                "default": {
                    "accentcolor": [ 0.443137254901961, 0.505882352941176, 0.556862745098039, 1.0 ],
                    "bgcolor": [ 0.796078431372549, 0.862745098039216, 0.925490196078431, 1.0 ],
                    "bgfillcolor": {
                        "angle": 270.0,
                        "autogradient": 0.0,
                        "color": [ 0.835294117647059, 0.901960784313726, 0.964705882352941, 1.0 ],
                        "color1": [ 0.031372549019608, 0.125490196078431, 0.211764705882353, 1.0 ],
                        "color2": [ 0.263682, 0.004541, 0.038797, 1.0 ],
                        "proportion": 0.39,
                        "type": "color"
                    },
                    "clearcolor": [ 0.898039, 0.898039, 0.898039, 1.0 ],
                    "color": [ 0.815686274509804, 0.509803921568627, 0.262745098039216, 1.0 ],
                    "editing_bgcolor": [ 0.898039, 0.898039, 0.898039, 1.0 ],
                    "elementcolor": [ 0.337254901960784, 0.384313725490196, 0.462745098039216, 1.0 ],
                    "fontname": [ "Lato" ],
                    "locked_bgcolor": [ 0.898039, 0.898039, 0.898039, 1.0 ],
                    "stripecolor": [ 0.309803921568627, 0.698039215686274, 0.764705882352941, 1.0 ],
                    "textcolor_inverse": [ 0.0, 0.0, 0.0, 1.0 ]
                },
                "parentstyle": "",
                "multi": 0
            },
            {
                "name": "rnbomonokai",
                "default": {
                    "accentcolor": [ 0.501960784313725, 0.501960784313725, 0.501960784313725, 1.0 ],
                    "bgcolor": [ 0.0, 0.0, 0.0, 1.0 ],
                    "bgfillcolor": {
                        "angle": 270.0,
                        "autogradient": 0.0,
                        "color": [ 0.0, 0.0, 0.0, 1.0 ],
                        "color1": [ 0.031372549019608, 0.125490196078431, 0.211764705882353, 1.0 ],
                        "color2": [ 0.263682, 0.004541, 0.038797, 1.0 ],
                        "proportion": 0.39,
                        "type": "color"
                    },
                    "clearcolor": [ 0.976470588235294, 0.96078431372549, 0.917647058823529, 1.0 ],
                    "color": [ 0.611764705882353, 0.125490196078431, 0.776470588235294, 1.0 ],
                    "editing_bgcolor": [ 0.976470588235294, 0.96078431372549, 0.917647058823529, 1.0 ],
                    "elementcolor": [ 0.749019607843137, 0.83921568627451, 1.0, 1.0 ],
                    "fontname": [ "Lato" ],
                    "locked_bgcolor": [ 0.976470588235294, 0.96078431372549, 0.917647058823529, 1.0 ],
                    "stripecolor": [ 0.796078431372549, 0.207843137254902, 1.0, 1.0 ],
                    "textcolor": [ 0.129412, 0.129412, 0.129412, 1.0 ]
                },
                "parentstyle": "",
                "multi": 0
            }
        ],
        "bgcolor": [ 0.031372549019608, 0.125490196078431, 0.211764705882353, 1.0 ]
    }
}