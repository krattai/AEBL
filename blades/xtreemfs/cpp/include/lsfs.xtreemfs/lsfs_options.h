/*
 * Copyright (c) 2011 by Michael Berlin, Zuse Institute Berlin
 *
 * Licensed under the BSD License, see LICENSE file for details.
 *
 */

#ifndef CPP_INCLUDE_LSFS_XTREEMFS_LSFS_OPTIONS_H_
#define CPP_INCLUDE_LSFS_XTREEMFS_LSFS_OPTIONS_H_

#include "libxtreemfs/options.h"

#include <boost/program_options.hpp>
#include <string>

#include "pbrpc/RPC.pb.h"
#include "xtreemfs/MRC.pb.h"

namespace xtreemfs {

class LsfsOptions : public Options {
 public:
  /** Sets the default values. */
  LsfsOptions();

  /** Set options parsed from command line which must contain at least the URL
   *  to a XtreemFS volume.
   *
   *  Calls Options::ParseCommandLine() to parse general options.
   *
   * @throws InvalidCommandLineParametersException
   * @throws InvalidURLException */
  void ParseCommandLine(int argc, char** argv);

  /** Shows only the minimal help text describing the usage of lsfs.xtreemfs.*/
  std::string ShowCommandLineUsage();

  /** Outputs usage of the command line parameters. */
  virtual std::string ShowCommandLineHelp();

  /** MRC admin_password as set in the MRC config. */
  std::string admin_password;

  /** The service_adresses of Options became service_address, so we can no
   *  longer use this option for the MRC address and need a new member.
   */
  std::string mrc_service_address;

 private:
  /** Contains all available lsfs options and its descriptions. */
  boost::program_options::options_description lsfs_descriptions_;

  /** Brief help text if there are no command line arguments. */
  std::string helptext_usage_;
};

}  // namespace xtreemfs

#endif  // CPP_INCLUDE_LSFS_XTREEMFS_LSFS_OPTIONS_H_
