import setuptools
from setuptools import setup

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(name='auto-run-anemoi',
      version='0.0.1',
      description='Tool for automatized execution of AnemoI training',
      long_description=long_description,
      long_description_content_type="text/markdown",
      url='http://github.com/metno/run-anemoi',
      author='Bris team',
      author_email='avnor2743@met.no',
      license='GNU GPL v3.0',
      packages=setuptools.find_packages(),
      test_suite='nose.collector',
      tests_require=['nose'],
      install_requires=['ruamel.yaml'],
      entry_points={
        'console_scripts': [
            'autorun=autorun_anemoi.cmd_interface:run'
        ]
      },
      zip_safe=False)

