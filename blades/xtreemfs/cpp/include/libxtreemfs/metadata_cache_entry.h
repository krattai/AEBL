/*
 * Copyright (c) 2011 by Michael Berlin, Zuse Institute Berlin
 *
 * Licensed under the BSD License, see LICENSE file for details.
 *
 */

#ifndef CPP_INCLUDE_LIBXTREEMFS_METADATA_CACHE_ENTRY_H_
#define CPP_INCLUDE_LIBXTREEMFS_METADATA_CACHE_ENTRY_H_

#include <stdint.h>

#include <string>

namespace xtreemfs {

namespace pbrpc {
class DirectoryEntries;
class Stat;
class listxattrResponse;
}

class MetadataCacheEntry {
 public:
  MetadataCacheEntry();
  ~MetadataCacheEntry();

  std::string path;

  xtreemfs::pbrpc::DirectoryEntries* dir_entries;
  uint64_t dir_entries_timeout_s;

  xtreemfs::pbrpc::Stat* stat;
  uint64_t stat_timeout_s;

  xtreemfs::pbrpc::listxattrResponse* xattrs;
  uint64_t xattrs_timeout_s;

  /** Always the maximum of all three timeouts. */
  uint64_t timeout_s;
};

}  // namespace xtreemfs

#endif  // CPP_INCLUDE_LIBXTREEMFS_METADATA_CACHE_ENTRY_H_
