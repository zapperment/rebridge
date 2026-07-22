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
        "rect": [ 339.0, 62.0, 2988.0, 1344.0 ],
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
                    "id": "obj-4",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "bang", "" ],
                    "patching_rect": [ 90.0, 980.0, 57.0, 20.0 ],
                    "text": "trigger b l"
                }
            },
            {
                "box": {
                    "annotation": "Connect a live.button",
                    "comment": "Connect a live.button",
                    "hint": "Connect a live.button",
                    "id": "obj-21",
                    "index": 0,
                    "maxclass": "outlet",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 320.0, 1140.0, 30.0, 30.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-12",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 500.0, 1030.0, 160.0, 20.0 ],
                    "text": "activebgcolor 1. 1. 1."
                }
            },
            {
                "box": {
                    "id": "obj-11",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 30.0, 1060.0, 150.0, 20.0 ],
                    "text": "activebgcolor 0. 0. 0."
                }
            },
            {
                "box": {
                    "id": "obj-7",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 80.0, 860.0, 87.0, 20.0 ],
                    "text": "parseHexColour"
                }
            },
            {
                "box": {
                    "id": "obj-6",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 80.0, 910.0, 120.0, 20.0 ],
                    "text": "prepend activebgcolor"
                }
            },
            {
                "box": {
                    "id": "obj-5",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 640.0, 940.0, 120.0, 20.0 ],
                    "text": "prepend activebgcolor"
                }
            },
            {
                "box": {
                    "id": "obj-2",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 640.0, 890.0, 87.0, 20.0 ],
                    "text": "parseHexColour"
                }
            },
            {
                "box": {
                    "id": "obj-41",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 975.0, 313.0, 29.5, 20.0 ],
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
                    "patching_rect": [ 925.0, 313.0, 29.5, 20.0 ],
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
                    "patching_rect": [ 875.0, 313.0, 29.5, 20.0 ],
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
                    "patching_rect": [ 875.0, 273.0, 119.0, 20.0 ],
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
                    "patching_rect": [ 915.0, 363.0, 102.0, 20.0 ],
                    "text": "textjustification $1"
                }
            },
            {
                "box": {
                    "id": "obj-19",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 755.0, 363.0, 153.0, 20.0 ],
                    "text": "presentation_rect 0. 0. $1 15."
                }
            },
            {
                "box": {
                    "id": "obj-10",
                    "maxclass": "newobj",
                    "numinlets": 6,
                    "numoutlets": 6,
                    "outlettype": [ "", "", "", "", "", "" ],
                    "patching_rect": [ 565.0, 85.0, 224.0, 20.0 ],
                    "text": "route label width align colour_on colour_off"
                }
            },
            {
                "box": {
                    "id": "obj-13",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 675.0, 363.0, 68.0, 20.0 ],
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
                    "patching_rect": [ 675.0, 433.0, 38.5, 15.0 ],
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
                    "patching_rect": [ 420.0, 40.0, 395.0, 20.0 ],
                    "text": "patcherargs @width 40 @align center @colour_on #ffffff @colour_off #000000"
                }
            },
            {
                "box": {
                    "annotation": "Connect a live.button with transition mode set to \"both\"",
                    "comment": "Connect a live.button with transition mode set to \"both\"",
                    "hint": "Connect a live.button with transition mode set to \"both\"",
                    "id": "obj-1",
                    "index": 0,
                    "maxclass": "inlet",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 210.0, 20.0, 30.0, 30.0 ]
                }
            },
            {
                "box": {
                    "code": "autowatch = 1;\ninlets = 3;\r\noutlets = 2;\n\nlet stored = null;\n\nfunction isTarget(cls) {\n    return cls === \"live.slider\" || cls === \"live.toggle\" || cls === \"live.dial\";\n}\n\nfunction bang() {\n    if (inlet === 0) store();\n    else if (inlet == 1) recall();\n    else clear();\n}\n\nfunction store() {\n    stored = [];\n    let obj = this.patcher.parentpatcher.firstobject;\n    while (obj) {\n        if (isTarget(obj.maxclass)) {\n            stored.push(obj.getvalueof());\n        }\n        obj = obj.nextobject;\n    }\r\n    outlet(1, \"bang\");\n}\n\nfunction recall() {\n    if (!stored) {\n        return;\n    }\n    let i = 0;\n    let obj = this.patcher.parentpatcher.firstobject;\n    while (obj) {\n        if (isTarget(obj.maxclass) && i < stored.length) {\n            obj.message(`float`, stored[i++]);\n        }\n        obj = obj.nextobject;\n    }\r\n}\n\nfunction clear() {\n    stored = null;\r\n    outlet(0, \"bang\");\n}",
                    "filename": "none",
                    "fontface": 0,
                    "fontname": "<Monospaced>",
                    "fontsize": 9.5,
                    "id": "obj-156",
                    "maxclass": "v8.codebox",
                    "numinlets": 3,
                    "numoutlets": 2,
                    "outlettype": [ "", "" ],
                    "patching_rect": [ 11.0, 332.0, 513.6752188801765, 400.8547049164772 ],
                    "saved_object_attributes": {
                        "parameter_enable": 0
                    }
                }
            },
            {
                "box": {
                    "id": "obj-149",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 3,
                    "outlettype": [ "bang", "bang", "bang" ],
                    "patching_rect": [ 210.0, 100.0, 104.0, 20.0 ],
                    "text": "multiController #1"
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "destination": [ "obj-149", 0 ],
                    "source": [ "obj-1", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-13", 0 ],
                    "midpoints": [ 574.5, 331.7343756556511, 684.5, 331.7343756556511 ],
                    "source": [ "obj-10", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-19", 0 ],
                    "midpoints": [ 615.5, 307.76953125, 764.5, 307.76953125 ],
                    "source": [ "obj-10", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 0 ],
                    "midpoints": [ 697.5, 799.28125, 649.5, 799.28125 ],
                    "source": [ "obj-10", 3 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-31", 0 ],
                    "midpoints": [ 656.5, 258.0078125, 884.5, 258.0078125 ],
                    "source": [ "obj-10", 2 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-7", 0 ],
                    "midpoints": [ 738.5, 830.61328125, 89.5, 830.61328125 ],
                    "source": [ "obj-10", 4 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-21", 0 ],
                    "source": [ "obj-11", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-21", 0 ],
                    "source": [ "obj-12", 0 ]
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
                    "destination": [ "obj-156", 2 ],
                    "source": [ "obj-149", 2 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-156", 1 ],
                    "source": [ "obj-149", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-156", 0 ],
                    "source": [ "obj-149", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-11", 0 ],
                    "source": [ "obj-156", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-12", 0 ],
                    "source": [ "obj-156", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-14", 0 ],
                    "midpoints": [ 924.5, 407.8515625, 684.5, 407.8515625 ],
                    "source": [ "obj-17", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-14", 0 ],
                    "midpoints": [ 764.5, 397.958984375, 684.5, 397.958984375 ],
                    "source": [ "obj-19", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-5", 0 ],
                    "source": [ "obj-2", 0 ]
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
                    "midpoints": [ 917.8333333333334, 301.966796875, 934.5, 301.966796875 ],
                    "source": [ "obj-31", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-41", 0 ],
                    "midpoints": [ 951.1666666666666, 302.490234375, 984.5, 302.490234375 ],
                    "source": [ "obj-31", 2 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-17", 0 ],
                    "midpoints": [ 884.5, 348.91796875, 924.5, 348.91796875 ],
                    "source": [ "obj-34", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-11", 1 ],
                    "source": [ "obj-4", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-11", 0 ],
                    "source": [ "obj-4", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-17", 0 ],
                    "midpoints": [ 934.5, 352.814453125, 924.5, 352.814453125 ],
                    "source": [ "obj-40", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-17", 0 ],
                    "midpoints": [ 984.5, 352.66015625, 924.5, 352.66015625 ],
                    "source": [ "obj-41", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-12", 1 ],
                    "source": [ "obj-5", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-4", 0 ],
                    "source": [ "obj-6", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-6", 0 ],
                    "source": [ "obj-7", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-10", 0 ],
                    "midpoints": [ 805.5, 73.97461003065109, 574.5, 73.97461003065109 ],
                    "source": [ "obj-8", 1 ]
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