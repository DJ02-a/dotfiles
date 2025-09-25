-- Python Import Picker Plugin
-- Interactive import suggestion and selection system for Python development

return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 
    'nvim-lua/plenary.nvim',
    'hrsh7th/nvim-cmp'
  },
  config = function()
    local pickers = require('telescope.pickers')
    local finders = require('telescope.finders')
    local conf = require('telescope.config').values
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    -- Python import 데이터베이스
    local import_db = {
      -- 표준 라이브러리
      ['os'] = {
        'import os',
        'from os import path, environ',
        'from os.path import join, exists, dirname, basename',
        'from os import listdir, makedirs, remove'
      },
      ['sys'] = {
        'import sys',
        'from sys import argv, path, exit',
        'from sys import stdin, stdout, stderr'
      },
      ['json'] = {
        'import json',
        'from json import loads, dumps',
        'from json import JSONEncoder, JSONDecoder'
      },
      ['datetime'] = {
        'import datetime',
        'from datetime import datetime, date, time',
        'from datetime import timedelta, timezone'
      },
      ['time'] = {
        'import time',
        'from time import sleep, time'
      },
      ['re'] = {
        'import re',
        'from re import match, search, findall, sub'
      },
      ['math'] = {
        'import math',
        'from math import pi, sqrt, sin, cos, tan'
      },
      ['random'] = {
        'import random',
        'from random import choice, randint, shuffle'
      },
      ['pathlib'] = {
        'import pathlib',
        'from pathlib import Path, PurePath'
      },
      ['typing'] = {
        'import typing',
        'from typing import List, Dict, Optional, Union',
        'from typing import Tuple, Set, Any, Callable'
      },
      ['collections'] = {
        'import collections',
        'from collections import defaultdict, Counter',
        'from collections import deque, OrderedDict'
      },
      ['itertools'] = {
        'import itertools',
        'from itertools import chain, combinations, permutations'
      },
      ['functools'] = {
        'import functools',
        'from functools import partial, reduce, wraps'
      },
      ['subprocess'] = {
        'import subprocess',
        'from subprocess import run, check_output, PIPE'
      },
      ['urllib'] = {
        'import urllib',
        'from urllib.request import urlopen, Request',
        'from urllib.parse import urlencode, quote'
      },
      ['logging'] = {
        'import logging',
        'from logging import getLogger, basicConfig, DEBUG, INFO'
      },
      
      -- 인기 있는 서드파티 라이브러리
      ['requests'] = {
        'import requests',
        'from requests import get, post, put, delete',
        'from requests.exceptions import RequestException'
      },
      ['numpy'] = {
        'import numpy as np',
        'from numpy import array, zeros, ones, arange',
        'from numpy import mean, std, sum, max, min'
      },
      ['pandas'] = {
        'import pandas as pd',
        'from pandas import DataFrame, Series',
        'from pandas import read_csv, read_json, to_datetime'
      },
      ['matplotlib'] = {
        'import matplotlib.pyplot as plt',
        'from matplotlib import pyplot as plt',
        'from matplotlib.figure import Figure'
      },
      ['seaborn'] = {
        'import seaborn as sns',
        'from seaborn import heatmap, scatterplot, lineplot'
      },
      ['sklearn'] = {
        'import sklearn',
        'from sklearn.model_selection import train_test_split',
        'from sklearn.linear_model import LinearRegression',
        'from sklearn.metrics import accuracy_score, classification_report'
      },
      ['torch'] = {
        'import torch',
        'import torch.nn as nn',
        'import torch.optim as optim',
        'from torch.utils.data import DataLoader, Dataset'
      },
      ['tensorflow'] = {
        'import tensorflow as tf',
        'from tensorflow import keras',
        'from tensorflow.keras import layers, Model'
      },
      ['flask'] = {
        'from flask import Flask, request, jsonify',
        'from flask import render_template, redirect, url_for'
      },
      ['django'] = {
        'from django.shortcuts import render, redirect',
        'from django.http import HttpResponse, JsonResponse',
        'from django.views import View'
      },
      ['fastapi'] = {
        'from fastapi import FastAPI, HTTPException',
        'from fastapi import Depends, Query, Path',
        'from pydantic import BaseModel'
      },
      ['sqlalchemy'] = {
        'from sqlalchemy import create_engine, Column, Integer, String',
        'from sqlalchemy.ext.declarative import declarative_base',
        'from sqlalchemy.orm import sessionmaker'
      },
      ['pytest'] = {
        'import pytest',
        'from pytest import fixture, mark, raises'
      },
      ['asyncio'] = {
        'import asyncio',
        'from asyncio import run, gather, create_task'
      },
      ['aiohttp'] = {
        'from aiohttp import ClientSession, web',
        'from aiohttp.web import Application, Response'
      },
      ['pydantic'] = {
        'from pydantic import BaseModel, Field',
        'from pydantic import validator, root_validator'
      },
      ['PIL'] = {
        'from PIL import Image, ImageDraw, ImageFont',
        'import PIL'
      },
      ['cv2'] = {
        'import cv2',
        'from cv2 import imread, imwrite, imshow'
      },
      ['yaml'] = {
        'import yaml',
        'from yaml import load, dump, safe_load'
      },
      ['dotenv'] = {
        'from dotenv import load_dotenv',
        'import dotenv'
      }
    }

    -- 자주 사용되는 함수명과 예상 라이브러리 매칭
    local function_to_library = {
      ['get'] = {'requests', 'dict'},
      ['post'] = {'requests'},
      ['put'] = {'requests'},
      ['delete'] = {'requests'},
      ['array'] = {'numpy'},
      ['DataFrame'] = {'pandas'},
      ['imread'] = {'cv2', 'PIL'},
      ['imwrite'] = {'cv2'},
      ['load_dotenv'] = {'dotenv'},
      ['sleep'] = {'time'},
      ['randint'] = {'random'},
      ['choice'] = {'random'},
      ['Path'] = {'pathlib'},
      ['datetime'] = {'datetime'},
      ['loads'] = {'json'},
      ['dumps'] = {'json'},
      ['run'] = {'subprocess', 'asyncio'},
      ['create_engine'] = {'sqlalchemy'},
      ['BaseModel'] = {'pydantic'},
      ['Flask'] = {'flask'},
      ['FastAPI'] = {'fastapi'}
    }

    -- 함수명 기반으로 추천 라이브러리 추출
    local function get_library_suggestions(word)
      local suggestions = {}
      
      -- 함수명 매칭으로 라이브러리 추천
      if function_to_library[word] then
        for _, lib in ipairs(function_to_library[word]) do
          if import_db[lib] then
            for _, imp in ipairs(import_db[lib]) do
              table.insert(suggestions, imp)
            end
          end
        end
      end
      
      return suggestions
    end

    -- Import 추천 생성
    local function get_suggestions(word)
      local suggestions = {}
      
      -- 정확한 라이브러리 매치
      if import_db[word] then
        for _, imp in ipairs(import_db[word]) do
          table.insert(suggestions, imp)
        end
      end
      
      -- 함수명 기반 추천
      local lib_suggestions = get_library_suggestions(word)
      for _, imp in ipairs(lib_suggestions) do
        table.insert(suggestions, imp)
      end
      
      -- 부분 매치로 라이브러리 찾기
      for lib, imports in pairs(import_db) do
        if lib:find(word) and lib ~= word then
          for _, imp in ipairs(imports) do
            table.insert(suggestions, imp)
          end
        end
      end
      
      -- 기본 import 패턴 제공
      if #suggestions == 0 or word ~= '' then
        table.insert(suggestions, 'import ' .. word)
        table.insert(suggestions, 'from ' .. word .. ' import ')
      end
      
      -- 커스텀 import 옵션
      table.insert(suggestions, '📝 Custom import...')
      
      return suggestions
    end

    -- 파일에 import 라인 추가
    local function add_import_to_file(import_line)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local insert_line = 0
      local found_imports = false
      
      -- 기존 import가 있는지 확인
      for i, line in ipairs(lines) do
        local trimmed = line:gsub("^%s*(.-)%s*$", "%1") -- trim
        
        -- import나 from ... import 라인 찾기
        if trimmed:match('^import ') or trimmed:match('^from .* import') then
          insert_line = i
          found_imports = true
        elseif found_imports and trimmed == '' then
          -- import 섹션 다음 빈 줄에서 멈춤
          break
        elseif found_imports and not (trimmed:match('^import ') or trimmed:match('^from .* import') or trimmed == '') then
          -- import가 아닌 다른 코드가 나오면 멈춤
          break
        elseif not found_imports and not (trimmed:match('^#') or trimmed:match('^"""') or trimmed:match("^'''") or trimmed == '') then
          -- 주석이나 docstring이 아닌 첫 번째 코드 라인 전에 insert
          insert_line = i - 1
          break
        end
      end
      
      -- import 라인이 없으면 파일 맨 앞에 추가
      if not found_imports then
        insert_line = 0
      end
      
      -- 중복 import 확인
      for _, line in ipairs(lines) do
        if line:gsub("^%s*(.-)%s*$", "%1") == import_line then
          print("Import already exists: " .. import_line)
          return
        end
      end
      
      vim.api.nvim_buf_set_lines(0, insert_line, insert_line, false, {import_line})
      print("Added: " .. import_line)
    end

    -- Telescope picker 생성
    local function import_picker(word)
      local suggestions = get_suggestions(word)
      
      if #suggestions == 0 then
        print("No import suggestions found for: " .. word)
        return
      end
      
      pickers.new({}, {
        prompt_title = "Select Import for '" .. word .. "'",
        finder = finders.new_table({
          results = suggestions,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            
            if selection[1] == '📝 Custom import...' then
              -- 커스텀 입력
              vim.ui.input({
                prompt = 'Enter custom import: ',
                default = 'from ' .. word .. ' import ',
              }, function(input)
                if input and input:gsub("^%s*(.-)%s*$", "%1") ~= '' then
                  add_import_to_file(input)
                end
              end)
            else
              add_import_to_file(selection[1])
            end
          end)
          
          -- 프리뷰 기능 (선택사항)
          map('i', '<C-p>', function()
            local selection = action_state.get_selected_entry()
            if selection then
              print("Preview: " .. selection[1])
            end
          end)
          
          return true
        end,
      }):find()
    end

    -- LSP integration - 추가적인 import 제안
    local function get_lsp_import_suggestions(word)
      -- 향후 LSP와 통합하여 더 정확한 제안을 받을 수 있음
      return {}
    end

    -- 전역 함수로 등록
    _G.python_import_picker = import_picker

    -- Auto command for Python files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "python",
      callback = function()
        -- Python 파일에서만 활성화되는 키맵
        vim.keymap.set('n', '<leader>pi', function()
          local word = vim.fn.expand('<cword>')
          if word and word ~= '' then
            python_import_picker(word)
          else
            print('No word under cursor')
          end
        end, { desc = 'Python Import Picker', buffer = true })
        
        vim.keymap.set('n', '<leader>I', function()
          local word = vim.fn.expand('<cword>')
          if word and word ~= '' then
            python_import_picker(word)
          else
            print('No word under cursor')
          end
        end, { desc = 'Python Import Picker', buffer = true })
      end,
    })

    -- Insert 모드에서 사용할 수 있는 함수
    local function insert_mode_import()
      local word = vim.fn.expand('<cword>')
      if word and word ~= '' then
        python_import_picker(word)
      else
        print('No word under cursor')
      end
    end

    -- CMP integration (optional)
    local cmp_ok, cmp = pcall(require, 'cmp')
    if cmp_ok then
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-i>'] = cmp.mapping(function(fallback)
            -- Python 파일에서만 동작
            if vim.bo.filetype == 'python' then
              insert_mode_import()
            else
              fallback()
            end
          end, { 'i' }),
        }),
      })
    end

    print("Python Import Picker loaded successfully!")
  end
}