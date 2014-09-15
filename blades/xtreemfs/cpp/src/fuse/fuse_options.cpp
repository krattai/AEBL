/*
 * Copyright (c) 2011 by Michael Berlin, Zuse Institute Berlin
 *
 * Licensed under the BSD License, see LICENSE file for details.
 *
 */

#include "fuse/fuse_options.h"

#include <csignal>

#include <boost/lexical_cast.hpp>
#include <boost/program_options/cmdline.hpp>
#include <boost/tokenizer.hpp>
#include <iostream>
#include <sstream>

#include "libxtreemfs/helper.h"
#include "libxtreemfs/xtreemfs_exception.h"

using namespace std;

namespace po = boost::program_options;
namespace style = boost::program_options::command_line_style;

namespace xtreemfs {

FuseOptions::FuseOptions() : Options(), fuse_descriptions_("Fuse Options") {
  // Overwrite certain members of Options().
#ifndef __linux
  // Interrupting read calls does not work with Linux Fuse.
  max_read_tries = 0;
#endif

  // Never give up to execute a request as we enabled interruption.
  max_tries = 0;
  max_write_tries = 0;

  async_writes_max_request_size_kb = 128;  // FUSE specific limit.

  // Default Fuse options.
#ifdef __APPLE__
  // We assume that the MacFuse default timeout is 60 seconds on Leopard.
  daemon_timeout = 60;

  // Always enable xattrs for Mac.
  enable_xattrs = true;

  // If we are under Leopard or newer, reduce the timeout values.
  if (GetMacOSXKernelVersion() >= 9) {
    max_tries = 3;
    max_read_tries = 3;
    max_write_tries = 3;

    retry_delay_s = 15;
    connect_timeout_s = 15;
    // The detection of a timeout may take twice the time, i.e. up to 18 seconds
    // resulting in a total time of 3 * 18 (< 60 seconds daemon_timeout default).
    request_timeout_s = 9;
  }
#else
  enable_xattrs = false;
#endif  // __APPLE__
  foreground = false;
  use_fuse_permission_checks = true;
  fuse_permission_checks_explicitly_disabled = false;

  fuse_descriptions_.add_options()
    ("foreground,f", po::value(&foreground)->zero_tokens(),
        "Do not fork into background.")
    ("fuse_option,o",
        po::value< vector<string> >(&fuse_options),
        "Passes -o=<option> to Fuse.")
    ("no-default-permissions",
        po::value(&fuse_permission_checks_explicitly_disabled)->zero_tokens(),
        "Do not pass -o default_permissions to Fuse (disables local Fuse"
        " permissions checks).");
  po::options_description fuse_options_information(
      "ACL and extended attributes Support:\n"
      "  -o xtreemfs_acl Enable the correct evaluation of XtreemFS ACLs.\n"
      "                  (Note that you cannot use the system tools getfattr\n"
      "                   and setfattr; use 'xtfsutil' instead to set and\n"
      "                   retrieve ACLs.)"
#ifndef __APPLE__
      "\n  -o user_xattr   Enable user defined extended attributes.");
#else
      );
#endif  // __APPLE__
  fuse_descriptions_.add(fuse_options_information);

  helptext_usage_ =
      "mount.xtreemfs: Mounts an XtreemFS Volume.\n"
      "\n"
      "Usage: \n"
      "\tmount.xtreemfs [options] [pbrpc[g|s]://]<dir-host>[:port]/<volume-name>"
          " <mount point>\n"
      "\n"
      "  Example: mount.xtreemfs localhost/myVolume ~/xtreemfs\n";
}

void FuseOptions::ParseCommandLine(int argc, char** argv) {
  // Parse general options and retrieve unregistered options for own parsing.
  vector<string> options = Options::ParseCommandLine(argc, argv);

  // Read Volume URL and mount point from command line.
  po::positional_options_description p;
  p.add("dir_volume_url", 1);
  p.add("mount_point", 1);
  po::options_description mount("Mount options");
  mount.add_options()
    ("dir_volume_url", po::value(&xtreemfs_url), "volume to mount")
    ("mount_point", po::value(&mount_point), "where to mount the volume");

  // Parse command line.
  po::options_description all_descriptions_;
  all_descriptions_.add(mount).add(fuse_descriptions_);
  po::variables_map vm;
  try {
    po::store(po::command_line_parser(options)
        .options(all_descriptions_)
        .positional(p)
        .style(style::default_style & ~style::allow_guessing)
        .run(), vm);
    po::notify(vm);
  } catch(const std::exception& e) {
    // Rethrow boost errors due to invalid command line parameters.
    throw InvalidCommandLineParametersException(string(e.what()));
  }

  // Do not check parameters if the help shall be shown.
  if (show_help || empty_arguments_list || show_version) {
    return;
  }

  // Split list of comma separated -o options and add them as extra options.
  list<string> split_options;
  for (int i = 0; i < fuse_options.size(); i++) {
    typedef boost::tokenizer< boost::char_separator<char> > tokenizer;
    boost::char_separator<char> seperator(",");
    tokenizer tokens(fuse_options[i], seperator);

    // Check if there are at least two tokens and they have to be split up
    tokenizer::iterator first_tokens = tokens.begin();
    if (++first_tokens != tokens.end()) {
      // Split tokens and add them to a temporary list.
      for (tokenizer::iterator token = tokens.begin();
           token != tokens.end();
           ++token) {
        split_options.push_back(string(*token));
      }

      // Remove split tokens from fuse_options as they will be readded later.
      fuse_options.erase(fuse_options.begin() + i);
      i--;
    }
  }
  // Readd split options.
  for (list<string>::const_iterator iter = split_options.begin();
       iter != split_options.end();
       ++iter) {
    fuse_options.push_back(*iter);
  }

  // Evaluate certain Fuse options.
  for (int i = 0; i < fuse_options.size(); i++) {
    if (fuse_options[i] == "acl") {
      throw InvalidCommandLineParametersException(
          "The option -o acl is not supported. Specify -o xtreemfs_acl instead."
          "\n\nWe do not allow -o acl because XtreemFS does not support the "
          "getfacl and setfacl tools. You have to use 'xtfs_acl' instead "
          "to set and retrieve ACLs.");
    }
    if (fuse_options[i] == "user_xattr") {
      enable_xattrs = true;
      // Don't send this option to Fuse.
      fuse_options.erase(fuse_options.begin() + i);
      i--;
      continue;
    }
    if (fuse_options[i] == "xtreemfs_acl") {
      // Fuse may prevent operations based on the evaluation of stat records
      // although a user is allowed to due to further ACLs, so we disable this
      // Fuse feature here.
      use_fuse_permission_checks = false;
      // Don't send this option to Fuse.
      fuse_options.erase(fuse_options.begin() + i);
      i--;
      continue;
    }
    if (fuse_options[i] == "intr") {
      // Don't send this option to Fuse.
      fuse_options.erase(fuse_options.begin() + i);
      i--;
      throw InvalidCommandLineParametersException(
          "The option -o intr will be ignored as command line parameter and"
          " not passed through to Fuse. Use --interrupt-signal instead.");
    }
    if (fuse_options[i].substr(0, 12) == "intr_signal=") {
      // Don't send this option to Fuse.
      fuse_options.erase(fuse_options.begin() + i);
      i--;
      throw InvalidCommandLineParametersException(
          "The option -o intr_signal will be ignored as command line "
          "parameter and not passed through to Fuse. Use --interrupt-signal "
          "instead.");
    }
    if (fuse_options[i] == "_netdev") {
      // Don't send this option to Fuse, just ignore it, solves issue 276:
      // https://code.google.com/p/xtreemfs/issues/detail?id=276
      fuse_options.erase(fuse_options.begin() + i);
      i--;
    }
#ifdef __APPLE__
    if (fuse_options[i].substr(0, 15) == "daemon_timeout=") {
      try {
        daemon_timeout = boost::lexical_cast<int>(fuse_options[i].substr(15));
        continue;
      } catch(const boost::bad_lexical_cast& e) {
        throw InvalidCommandLineParametersException(
            "The integer value after daemon_timeout could not be parsed: "
            + fuse_options[i].substr(15));
      }
    }
#endif
  }

  // Extract information from command line.
  Options::ParseURL(kDIR);

  // Check for required parameters.
  if (service_addresses.empty()) {
    throw InvalidCommandLineParametersException("missing DIR host.");
  }
  if (volume_name.empty()) {
    throw InvalidCommandLineParametersException("missing volume name.");
  }
  if (mount_point.empty()) {
    throw InvalidCommandLineParametersException("missing mount point.");
  }
}

std::string FuseOptions::ShowCommandLineUsage() {
  return helptext_usage_
      + "\nFor complete list of options, please specify -h or --help.\n";
}

std::string FuseOptions::ShowCommandLineHelp() {
  ostringstream stream;
  // No help text given in descriptions for positional mount options. Instead
  // the usage is explained here.
  stream << helptext_usage_
         << endl
         // Descriptions of this class.
         << fuse_descriptions_
         // Descriptions of the general options.
         << Options::ShowCommandLineHelp();
  return stream.str();
}

}  // namespace xtreemfs
