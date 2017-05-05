/*
 * Copyright (c) 2012 by Michael Berlin, Zuse Institute Berlin
 *
 * Licensed under the BSD License, see LICENSE file for details.
 *
 */

#ifndef CPP_INCLUDE_CBFS_CBFS_OPTIONS_H_
#define CPP_INCLUDE_CBFS_CBFS_OPTIONS_H_

#include "libxtreemfs/options.h"

#include <boost/program_options.hpp>
#include <string>
#include <vector>

namespace xtreemfs {

class CbFSOptions : public Options {
 public:
  /** Sets the default values. */
  CbFSOptions();

  /** Set options parsed from command line which must contain at least the URL
   *  to a XtreemFS volume and a mount point.
   *
   *  Calls Options::ParseCommandLine() to parse general options.
   *
   * @throws InvalidCommandLineParametersException
   * @throws InvalidURLException */
  void ParseCommandLine(int argc, char** argv);

  /** Shows only the minimal help text describing the usage of mount.xtreemfs.*/
  std::string ShowCommandLineUsage();

  /** Outputs usage of the command line parameters. */
  virtual std::string ShowCommandLineHelp();

  // CbFS options.

 private:
  /** Contains all available CbFS options and its descriptions. */
  boost::program_options::options_description cbfs_descriptions_;

  /** Brief help text if there are no command line arguments. */
  std::string helptext_usage_;
};

}  // namespace xtreemfs

#endif  // CPP_INCLUDE_CBFS_CBFS_OPTIONS_H_
