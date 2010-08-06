#!/usr/bin/env python

import optparse
import os
import re
import shutil

# Location of compiler
MXMLC_PATH = 'mxmlc -debug -verbose-stacktraces -incremental=true -compiler.strict -compiler.show-actionscript-warnings -static-link-runtime-shared-libraries=true -define=FP::complete,false'

# For replacing .as with .swf
as_re = re.compile('\.as$|\.mxml$')

def flex_pilot():
    cmd = MXMLC_PATH + ' -source-path=./src ./src/org/flex_pilot/FlexPilot.as -o ./org/flex_pilot/FlexPilot.swf'
    os.system(cmd)

def bootstrap():
    cmd = MXMLC_PATH + ' -source-path=./src ./src/org/flex_pilot/FPBootstrap.as -o ./org/flex_pilot/FPBootstrap.swf'
    os.system(cmd)

def clean():
    for root, dirs, file_list in os.walk('./'):
        for file in file_list:
            if file.endswith('.swf') or file.endswith('.swc') or file.endswith('.swf.cache'):
                path = root + '/' + file
                cmd = 'rm ' + path
                #print cmd
                os.system(cmd)

def parse_opts():
    parser = optparse.OptionParser()
    parser.add_option('-t', '--target', dest='target',
            help='build TARGET (flex_pilot/bootstrap/all/clean, default is all)',
            metavar='TARGET', choices=('flex_pilot', 'bootstrap', 'all', 'clean'), default='all')
    opts, args = parser.parse_args()
    return opts, args

def main(o, a):
    target = o.target
    # Build only the AS tests into loadable swfs
    if target == 'flex_pilot':
        flex_pilot()
    # Build only the test app we use to run the tests against
    elif target == 'bootstrap':
        bootstrap()
    # Build everything, natch
    elif target == 'all':
        flex_pilot()
        bootstrap()
    # Clean out any swfs in the directory
    elif target == 'clean':
        clean()
    else:
        print 'Not a valid target.'

if __name__ == "__main__":
    main(*parse_opts())


