#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
from api import kb, sendSticker, sendPoll


def inlineRep(dest, msg, btn, rep_data):
    clavier = '[[%7B"text":"{0}","callback_data":"{1}"%7D]]'.format(btn, rep_data)
    kb (dest, msg, clavier, 'inline_keyboard')


def inlineDouble(dest, msg, btn, rep_data, btn2, rep_data2):
    clavier = '[[%7B"text:"{0}","callback_data":"{1}"%7D,%7B"text":"{2}","callback_data":"{3}"%7D]]'.format(btn, rep_data, btn2, rep_data2)
    kb (dest, msg, clavier, 'inline_keyboard')


def removeKb(dest):
    kb (dest, '✅', 'noKb', 'remove_keyboard')




if (sys.argv[1] == 'inlineRep'):
    inlineRep (sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])

elif (sys.argv[1] == 'inlineDouble'):
    inlineDouble (sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6], sys.arg[7])

elif (sys.argv[1] == 'removeKb'):
    removeKb (sys.argv[2])

elif (sys.argv[1] == 'sticker'):
    sendSticker (sys.argv[2], sys.argv[3])

elif (sys.argv[1] == 'sendPoll'):
    sendPoll (sys.argv[2], sys.argv[3], sys.argv[4])

