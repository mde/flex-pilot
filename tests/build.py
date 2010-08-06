#!/usr/bin/env python

import optparse
import os
import re
import shutil

# Location of compiler
MXMLC_PATH = 'mxmlc -debug -verbose-stacktraces -incremental=true -compiler.strict -compiler.show-actionscript-warnings -static-link-runtime-shared-libraries=true -define=FP::complete,false'

# For replacing .as with .swf
as_re = re.compile('\.as$|\.mxml$')

def app():
    cmd = MXMLC_PATH + ' -source-path=. -source-path+=../src ./TestApp.mxml -o ./TestApp.swf'
    print cmd
    os.system(cmd)

def accordion():
    cmd = MXMLC_PATH + ' -source-path=. -source-path+=../src ./TestAccordion.mxml -o ./TestAccordion.swf'
    print cmd
    os.system(cmd)

def fptestapp():
    cmd = MXMLC_PATH + ' -source-path=. -source-path+=../src ./FlexPilotTest.mxml -o ./FlexPilotTest.swf'
    print cmd
    os.system(cmd)

def tests():
    for root, dirs, file_list in os.walk('./'):
            for file in file_list:
                if file.endswith('.as') and file != 'TestAppCode.as':
                    as_file = root + file
                    swf_file = as_re.sub('.swf', as_file)
                    # Compile this biyatch
                    # -----------------------
                    cmd = MXMLC_PATH + ' -source-path=. -source-path+=../src ' + as_file + ' -o ' + swf_file
                    #print cmd
                    os.system(cmd)

def clean():
    for root, dirs, file_list in os.walk('./'):
        for file in file_list:
            if file.endswith('.swf') or file.endswith('.swc'):
                path = root + '/' + file
                cmd = 'rm ' + path
                #print cmd
                os.system(cmd)

def parse_opts():
    parser = optparse.OptionParser()
    parser.add_option('-t', '--target', dest='target',
            help='build TARGET (tests/app/all/clean, default is all)',
            metavar='TARGET', choices=('tests', 'app', 'all', 'clean'), default='all')
    opts, args = parser.parse_args()
    return opts, args

def main(o, a):
    target = o.target
    # Build only the AS tests into loadable swfs
    if target == 'tests':
        tests()
    # Build only the test app we use to run the tests against
    elif target == 'app':
        app()
    elif target == 'accordion':
        accordion()
    # Build everything, natch
    elif target == 'all':
        app()
        accordion()
        fptestapp()
        tests()
    # Clean out any swfs in the directory
    elif target == 'clean':
        clean()
    else:
        print 'Not a valid target.'

if __name__ == "__main__":
    main(*parse_opts())


