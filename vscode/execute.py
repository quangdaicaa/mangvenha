import sys, os, subprocess, uuid

def breakpath(path:str) -> tuple[str,str,str]:
  '''return folder, filname, ext'''
  path=path.split('/')
  folder = '/'.join(path[:-1])
  filename = path[-1].split('.')
  len_ = len(filename)
  if len_ == 1: return folder, filename[0], ''
  elif len_ == 2: return folder, filename[0], filename[-1]
  else: return folder, '.'.join(filename[:-1]), filename[-1]

def run(code:str|list) -> None:
  if isinstance(code, str): subprocess.run(code.split(' '))
  else: subprocess.run(code)

version = ''.join(sys.version.split('.')[:2])
home = os.getcwd()
path, mode, *_ = sys.argv[1:]
folder, filename, ext = breakpath(path)

include = '/usr/include/python3.11'
java_env = '/usr/lib/jdk-21/bin'
go_env = '/usr/lib/go1.19.4/bin'
python_env = '/usr/bin/python3.11'
nodejs_env = '/usr/lib/nodejs19.2.0'
typescript_env = f'{nodejs_env}/bin/node_modules/typescript/bin'
npm_env = f'{nodejs_env}/node {nodejs_env}/bin/npm'
pip_env = f'~/.local/bin/pip'
inventory='/usr/cloud/inventory.yml'

if mode == 'exe':
  if ext == 'py':
    run(f'{python_env} {path}')
  elif ext == 'sh':
    run(f'chmod +x {path}')
    run(f'zsh {path}')
  elif ext == 'java':
    run(f'{java_env}/javac {path}')
    os.chdir(folder)
    run(f'{java_env}/java {filename}')
    os.chdir(home)
  elif ext == 'go':
    run(f'{go_env}/go build -o {folder}/{filename}.so {path}')
    run(f'{folder}/{filename}.so')
  elif ext == 'cpp':
    run(f'g++ -I {include} {folder}/{filename}.cpp -o {folder}/{filename}.so')
    run(f'{folder}/{filename}.so')
  elif ext == 'js':
    run(f'{nodejs_env}/node {path}')
  elif ext == 'ts':
    run(f'{nodejs_env}/node {typescript_env}/tsc {path}')
    run(f'{nodejs_env}/node {folder}/{filename}.js')
  elif ext == 'pyx':
    from distutils.core import setup
    from Cython.Build import cythonize
    import importlib.util
    so = f'{filename}.cpython-{version}-x86_64-linux-gnu.so'
    try:
      setup(
        ext_modules=cythonize(path, annotate=True), 
        script_args=['build_ext'],                                        
        options={'build_ext':{'inplace':True}},
        include_dirs=[include]
        )
    except:
      run(f'rm {folder}/{filename}.c')
      run(f'rm {folder}/{filename}.html')
    run(f'mv {so} {folder}/{so}')
    run('rm -rf build')
    pyx = importlib.util.spec_from_file_location(filename, f'{folder}/{so}')
    pyx.loader.exec_module(importlib.util.module_from_spec(pyx))
  elif ext == 'dock':
    run(f'sudo docker image rm -f {filename}')
    run(f'sudo docker build {folder} -f {path} -t {filename}')
  elif ext == 'yml' or ext == 'yaml':
    run(f'ansible-playbook -i {inventory} {path}')


if mode == 'test':
  if ext == 'py' or ext =='pyx':
    filetest = f'{folder}/{filename}_test.py'
    if os.path.exists(filetest):
      run(f'{python_env} {filetest}')
    else:
      open(filetest, 'w').write(f'''\
import unittest
import {filename}

class {filename}_test(unittest.TestCase):
  def test_func(self):
    # self.assertEqual(func(*arg), ret)
    pass

if __name__ == '__main__':
  unittest.main()
''')
      run(f'{python_env} {filetest}')

if mode == 'add':
  run(f'git branch -M main')
  run(f'git add {path}')
  run(f'git commit -m {uuid.uuid4()}')