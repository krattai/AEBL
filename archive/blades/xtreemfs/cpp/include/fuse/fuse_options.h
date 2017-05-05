/*
 * Copyright (c) 2011 by Michael Berlin, Zuse Institute Berlin
 *
 * Licensed under the BSD License, see LICENSE file for details.
 *
 */

#ifndef CPP_INCLUDE_FUSE_FUSE_OPTIONS_H_
#define CPP_INCLUDE_FUSE_FUSE_OPTIONS_H_

#include "libxtreemfs/options.h"

#include <boost/program_options.hpp>
#include <string>
#include <vector>

namespace xtreemfs {

class FuseOptions : public Options {
 public:
  /** Sets the default values. */
  FuseOptions();

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

  // Fuse options.
  /** Execute extended attributes operations? */
  bool enable_xattrs;
  /** If -o default_permissions is passed to Fuse, there are no extra permission
   *  checks needed. */
  bool use_fuse_permission_checks;
  /** If requested by the user, do not pass -o default_permissions to Fuse. */
  bool fuse_permission_checks_explicitly_disabled;
  /** Run the adapter program in foreground or send it to background? */
  bool foreground;
  /** Fuse options specified by -o. */
  std::vector<std::string> fuse_options;
#ifdef __APPLE__
  /** Assumed (or if specified the set) timeout of a blocked operation after
   *  which MacFuse will on a) Tiger show a dialog if the user will still wait
   *  for the operation or b) >=Leopard just kill our Fuse implementation and
   *  call fuse_destroy.
   */
  int daemon_timeout;
#endif  // __APPLE__

 private:
  /** Contains all available Fuse options and its descriptions. */
  boost::program_options::options_description fuse_descriptions_;

  /** Brief help text if there are no command line arguments. */
  std::string helptext_usage_;
};

}  // namespace xtreemfs

#endif  // CPP_INCLUDE_FUSE_FUSE_OPTIONS_H_
