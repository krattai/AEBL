/*
 * Copyright (c) 2008-2011 by Jan Stender,
 *               Zuse Institute Berlin
 *
 * Licensed under the BSD License, see LICENSE file for details.
 *
 */

package org.xtreemfs.mrc.database.babudb;

import java.nio.ByteBuffer;
import java.util.List;
import java.util.Map.Entry;

import org.xtreemfs.babudb.api.database.Database;
import org.xtreemfs.babudb.api.database.DatabaseRO;
import org.xtreemfs.babudb.api.database.ResultSet;
import org.xtreemfs.babudb.api.exception.BabuDBException;
import org.xtreemfs.foundation.logging.Logging;
import org.xtreemfs.foundation.logging.Logging.Category;
import org.xtreemfs.mrc.database.DatabaseResultSet;
import org.xtreemfs.mrc.metadata.ACLEntry;
import org.xtreemfs.mrc.metadata.BufferBackedACLEntry;
import org.xtreemfs.mrc.metadata.BufferBackedFileMetadata;
import org.xtreemfs.mrc.metadata.BufferBackedRCMetadata;
import org.xtreemfs.mrc.metadata.BufferBackedXAttr;
import org.xtreemfs.mrc.metadata.FileMetadata;
import org.xtreemfs.mrc.metadata.XAttr;

public class BabuDBStorageHelper {
    
    static class ChildrenIterator implements DatabaseResultSet<FileMetadata> {
        
        private final DatabaseRO                database;
        
        private final ResultSet<byte[], byte[]> it;
        
        private Entry<byte[], byte[]>           next;
        
        private String                          prevFileName;
        
        private byte[][]                        keyBufs;
        
        private byte[][]                        valBufs;
        
        private int                             remaining;
        
        public ChildrenIterator(DatabaseRO database, ResultSet<byte[], byte[]> it, int from, int num) {
            
            this.database = database;
            this.it = it;
            
            this.keyBufs = new byte[BufferBackedFileMetadata.NUM_BUFFERS][];
            this.valBufs = new byte[BufferBackedFileMetadata.NUM_BUFFERS][];
            
            remaining = Integer.MAX_VALUE;
            
            // move to the 'from' element
            for (int i = 0; i < from && hasNext(); i++)
                next();
            
            remaining = num;
        }
        
        @Override
        public boolean hasNext() {
            return (next != null || it.hasNext()) && remaining > 0;
        }
        
        @Override
        public FileMetadata next() {
            
            while (next != null || it.hasNext()) {
                
                if (next == null)
                    next = it.next();
                
                final String currFileName = new String(next.getKey(), 8, next.getKey().length - 9);
                
                if (prevFileName != null && !prevFileName.equals(currFileName)) {
                    assert (valBufs[FileMetadata.RC_METADATA] != null) : "*** DATABASE CORRUPTED *** incomplete file metadata";
                    break;
                }
                
                final byte currType = next.getKey()[next.getKey().length - 1];
                
                keyBufs[currType] = next.getKey();
                valBufs[currType] = next.getValue();
                next = null;
                
                prevFileName = currFileName;
            }
            
            byte[][] tmpKeys = keyBufs;
            byte[][] tmpVals = valBufs;
            keyBufs = new byte[BufferBackedFileMetadata.NUM_BUFFERS][];
            valBufs = new byte[BufferBackedFileMetadata.NUM_BUFFERS][];
            
            // if (tmpVals[FileMetadata.RC_METADATA] == null) {
            // //dump the record
            // for (int i = 0; i < tmpVals.length; i++) {
            // System.out.println("index "+i);
            // if (tmpVals[i] == null) {
            // System.out.println("IS NULL!");
            // continue;
            // }
            // String content = new String(tmpVals[i]);
            // System.out.println("content: "+content);
            // }
            // System.exit(1);
            // }
            
            BufferBackedFileMetadata md = null;
            
            // in case of a hardlink ...
            if (tmpVals[FileMetadata.RC_METADATA][0] == 2)
                try {
                    md = BabuDBStorageHelper.resolveLink(database, tmpVals[FileMetadata.RC_METADATA],
                        prevFileName);
                } catch (BabuDBException exc) {
                    Logging.logMessage(Logging.LEVEL_ERROR, Category.storage, this,
                        "could not resolve hard link");
                }
            
            else
                md = new BufferBackedFileMetadata(tmpKeys, tmpVals, BabuDBStorageManager.FILE_INDEX);
            
            remaining--;
            
            prevFileName = null;
            return md;
        }
        
        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }
        
        public void destroy() {
            it.free();
        }
        
    }
    
    static class XAttrIterator implements DatabaseResultSet<XAttr> {
        
        private ResultSet<byte[], byte[]> it;
        
        private String                    owner;
        
        private BufferBackedXAttr         next;
        
        public XAttrIterator(ResultSet<byte[], byte[]> it, String owner) {
            this.it = it;
            this.owner = owner;
        }
        
        @Override
        public boolean hasNext() {
            
            if (owner == null)
                return it.hasNext();
            
            if (next != null)
                return true;
            
            if (!it.hasNext())
                return false;
            
            while (it.hasNext()) {
                
                Entry<byte[], byte[]> tmp = it.next();
                next = new BufferBackedXAttr(tmp.getKey(), tmp.getValue());
                if (!owner.equals(next.getOwner()))
                    continue;
                
                return true;
            }
            
            return false;
        }
        
        @Override
        public XAttr next() {
            
            if (next != null) {
                XAttr tmp = next;
                next = null;
                return tmp;
            }
            
            for (;;) {
                
                Entry<byte[], byte[]> tmp = it.next();
                
                next = new BufferBackedXAttr(tmp.getKey(), tmp.getValue());
                if (owner != null && !owner.equals(next.getOwner()))
                    continue;
                
                BufferBackedXAttr tmp2 = next;
                next = null;
                return tmp2;
            }
        }
        
        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }
        
        public void destroy() {
            it.free();
        }
        
    }
    
    static class ACLIterator implements DatabaseResultSet<ACLEntry> {
        
        private ResultSet<byte[], byte[]> it;
        
        public ACLIterator(ResultSet<byte[], byte[]> it) {
            this.it = it;
        }
        
        @Override
        public boolean hasNext() {
            return it.hasNext();
        }
        
        @Override
        public ACLEntry next() {
            Entry<byte[], byte[]> entry = it.next();
            return new BufferBackedACLEntry(entry.getKey(), entry.getValue());
        }
        
        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }
        
        public void destroy() {
            it.free();
        }
        
    }
    
    public static byte[] getLastAssignedFileId(Database database) throws BabuDBException {
        
        byte[] bytes = database.lookup(BabuDBStorageManager.VOLUME_INDEX, BabuDBStorageManager.LAST_ID_KEY,
            null).get();
        
        if (bytes == null) {
            bytes = new byte[8];
            ByteBuffer tmp = ByteBuffer.wrap(bytes);
            tmp.putLong(0);
        }
        
        return bytes;
    }
    
    public static byte[] getVolumeMetadata(DatabaseRO database, byte[] key) throws BabuDBException {
        
        byte[] bytes = database.lookup(BabuDBStorageManager.VOLUME_INDEX, key, null).get();
        
        if (bytes == null) {
            bytes = new byte[8];
            ByteBuffer tmp = ByteBuffer.wrap(bytes);
            tmp.putLong(0);
        }
        
        return bytes;
    }
    
    /**
     * Returns the collision number assigned to an extended attribute, -1 if the
     * attribute does not exist.
     * 
     * @param database
     * @param fileId
     * @param owner
     * @param attrKey
     * @return the collision number
     * @throws BabuDBException
     */
    public static short findXAttrCollisionNumber(Database database, long fileId, String owner, String attrKey)
        throws BabuDBException {
        
        // first, determine the collision number
        byte[] prefix = createXAttrPrefixKey(fileId, owner, attrKey);
        ResultSet<byte[], byte[]> it = database.prefixLookup(BabuDBStorageManager.XATTRS_INDEX, prefix, null)
                .get();
        
        Entry<byte[], byte[]> next = null;
        while (it.hasNext()) {
            
            Entry<byte[], byte[]> curr = it.next();
            BufferBackedXAttr attr = new BufferBackedXAttr(curr.getKey(), curr.getValue());
            
            if (owner.equals(attr.getOwner()) && attrKey.equals(attr.getKey())) {
                next = curr;
                break;
            }
        }
        
        it.free();
        
        if (next == null)
            return -1;
        
        return getXAttrCollisionNumber(next.getKey());
    }
    
    /**
     * Returns the collision number assigned to an extended attribute, or the
     * next largest unused number if the attribute does not exist.
     * 
     * @param database
     * @param fileId
     * @param owner
     * @param attrKey
     * @return the collision number
     * @throws BabuDBException
     */
    public static short findUsedOrNextFreeXAttrCollisionNumber(Database database, long fileId, String owner,
        String attrKey) throws BabuDBException {
        
        // first, determine the collision number
        byte[] prefix = createXAttrPrefixKey(fileId, owner, attrKey);
        ResultSet<byte[], byte[]> it = database.prefixLookup(BabuDBStorageManager.XATTRS_INDEX, prefix, null)
                .get();
        
        Entry<byte[], byte[]> next = null;
        Entry<byte[], byte[]> curr = null;
        while (it.hasNext()) {
            
            curr = it.next();
            BufferBackedXAttr attr = new BufferBackedXAttr(curr.getKey(), curr.getValue());
            
            if (owner.equals(attr.getOwner()) && attrKey.equals(attr.getKey())) {
                next = curr;
                break;
            }
        }
        
        it.free();
        
        if (next == null)
            return curr == null ? 0 : (short) (getXAttrCollisionNumber(curr.getKey()) + 1);
        
        return getXAttrCollisionNumber(next.getKey());
    }
    
    public static byte[] createFileKey(long parentId, String fileName, byte type) {
        
        byte[] bytes = fileName.getBytes();
        
        byte[] prefix = new byte[(type >= 0 ? 9 : 8) + bytes.length];
        ByteBuffer buf = ByteBuffer.wrap(prefix);
        buf.putLong(parentId).put(bytes);
        if (type >= 0)
            buf.put(type);
        
        return prefix;
    }
    
    public static byte[] createXAttrPrefixKey(long fileId, String owner, String attrKey) {
        
        byte[] prefix = new byte[owner == null ? 8 : attrKey == null ? 12 : 16];
        ByteBuffer buf = ByteBuffer.wrap(prefix);
        buf.putLong(fileId);
        if (owner != null)
            buf.putInt(owner.hashCode());
        if (attrKey != null)
            buf.putInt(attrKey.hashCode());
        
        return prefix;
    }
    
    public static byte[] createFilePrefixKey(long parentId) {
        
        byte[] prefix = new byte[8];
        ByteBuffer buf = ByteBuffer.wrap(prefix);
        buf.putLong(parentId);
        
        return prefix;
    }
    
    public static byte[] createACLPrefixKey(long fileId, String entityName) {
        
        byte[] entityBytes = entityName == null ? new byte[0] : entityName.getBytes();
        byte[] prefix = new byte[8 + entityBytes.length];
        ByteBuffer buf = ByteBuffer.wrap(prefix);
        buf.putLong(fileId).put(entityBytes);
        
        return prefix;
    }
    
    public static byte[] createFileIdIndexValue(long parentId, String fileName) {
        
        byte[] nameBytes = fileName.getBytes();
        
        byte[] buf = new byte[8 + nameBytes.length];
        ByteBuffer tmp = ByteBuffer.wrap(buf);
        tmp.putLong(parentId).put(nameBytes);
        
        return buf;
    }
    
    public static byte[] createFileIdIndexKey(long fileId, byte type) {
        
        byte[] buf = new byte[type == -1 ? 8 : 9];
        ByteBuffer tmp = ByteBuffer.wrap(buf);
        tmp.putLong(fileId);
        if (type != -1)
            tmp.put(type);
        
        return buf;
    }
    
    public static byte[] createLinkTarget(long fileId) {
        
        byte[] buf = new byte[9];
        ByteBuffer tmp = ByteBuffer.wrap(buf);
        tmp.put((byte) 2).putLong(fileId);
        
        return buf;
    }
    
    public static short getXAttrCollisionNumber(byte[] key) {
        
        short collNum = 0;
        ByteBuffer tmp = ByteBuffer.wrap(key);
        if (key.length == 16)
            collNum = 0;
        else
            collNum = tmp.getShort(16);
        
        return collNum;
    }
    
    public static BufferBackedFileMetadata getMetadata(DatabaseRO database, long parentId, String fileName)
        throws BabuDBException {
        
        byte[] rcKey = BabuDBStorageHelper.createFileKey(parentId, fileName, FileMetadata.RC_METADATA);
        byte[] rcValue = database.lookup(BabuDBStorageManager.FILE_INDEX, rcKey, null).get();
        
        if (rcValue != null) {
            
            // if the value refers to a link, resolve the link
            if (rcValue[0] == 2)
                return resolveLink(database, rcValue, fileName);
            
            byte[] fcKey = BabuDBStorageHelper.createFileKey(parentId, fileName, FileMetadata.FC_METADATA);
            byte[] fcValue = database.lookup(BabuDBStorageManager.FILE_INDEX, fcKey, null).get();
            
            byte[][] keyBufs = new byte[][] { fcKey, rcKey };
            byte[][] valBufs = new byte[][] { fcValue, rcValue };
            
            return new BufferBackedFileMetadata(keyBufs, valBufs, BabuDBStorageManager.FILE_INDEX);
        }

        else
            return null;
        
    }
    
    public static long getId(Database database, long parentId, String fileName, Boolean directory)
        throws BabuDBException {
        
        byte[] key = createFileKey(parentId, fileName, BufferBackedFileMetadata.RC_METADATA);
        byte[] value = database.lookup(BabuDBStorageManager.FILE_INDEX, key, null).get();
        
        if (value == null)
            return -1;
        
        return ByteBuffer.wrap(value).getLong(1);
    }
    
    public static byte getType(byte[] key, int index) {
        return key[index == BabuDBStorageManager.FILE_ID_INDEX ? 8 : 12];
    }
    
    public static BufferBackedFileMetadata resolveLink(DatabaseRO database, byte[] target, String fileName)
        throws BabuDBException {
        
        ResultSet<byte[], byte[]> it = null;
        
        try {
            // determine the key for the link index
            byte[] fileIdBytes = new byte[8];
            System.arraycopy(target, 1, fileIdBytes, 0, fileIdBytes.length);
            
            byte[][] valBufs = new byte[BufferBackedFileMetadata.NUM_BUFFERS][];
            
            // retrieve the metadata from the link index
            it = database.prefixLookup(BabuDBStorageManager.FILE_ID_INDEX,
                fileIdBytes, null).get();
            
            while (it.hasNext()) {
                
                Entry<byte[], byte[]> curr = it.next();
                
                int type = getType(curr.getKey(), BabuDBStorageManager.FILE_ID_INDEX);
                if (type == 3) {
                    long fileId = ByteBuffer.wrap(fileIdBytes).getLong();
                    Logging.logMessage(Logging.LEVEL_WARN, Category.storage, (Object) null,
                        "MRC database contains redundant data for file %d", fileId);
                    continue;
                }
                valBufs[type] = curr.getValue();
            }
            
            assert (valBufs[FileMetadata.RC_METADATA] != null) : "*** DATABASE CORRUPTED *** dangling hardlink";
            if (valBufs[FileMetadata.RC_METADATA] == null)
                return null;
            
            // replace the file name with the link name
            BufferBackedRCMetadata tmp = new BufferBackedRCMetadata(null, valBufs[FileMetadata.RC_METADATA]);
            BufferBackedRCMetadata tmp2 = tmp.isDirectory() ? new BufferBackedRCMetadata(0, fileName, tmp
                    .getOwnerId(), tmp.getOwningGroupId(), tmp.getId(), tmp.getPerms(), tmp.getW32Attrs(), tmp
                    .getLinkCount()) : new BufferBackedRCMetadata(0, fileName, tmp.getOwnerId(), tmp
                    .getOwningGroupId(), tmp.getId(), tmp.getPerms(), tmp.getW32Attrs(), tmp.getLinkCount(), tmp
                    .getEpoch(), tmp.getIssuedEpoch(), tmp.isReadOnly());
            if (!tmp2.isDirectory())
                tmp2.setXLocList(tmp.getXLocList());
            valBufs[FileMetadata.RC_METADATA] = tmp2.getValue();
            byte[][] keyBufs = new byte[][] { null, tmp2.getKey() };
            
            return new BufferBackedFileMetadata(keyBufs, valBufs, BabuDBStorageManager.FILE_ID_INDEX);
        
        } finally {
            if (it != null)
                it.free();
        }
    }
    
    public static ChildrenIterator getChildren(DatabaseRO database, long parentId, int from, int num)
        throws BabuDBException {
        
        byte[] prefix = BabuDBStorageHelper.createFilePrefixKey(parentId);
        ResultSet<byte[], byte[]> it = database.prefixLookup(BabuDBStorageManager.FILE_INDEX, prefix, null)
                .get();
        
        return new ChildrenIterator(database, it, from, num);
    }
    
    public static void getNestedFiles(List<FileMetadata> files, Database database, long dirId,
        boolean recursive) throws BabuDBException {
        
        ChildrenIterator children = getChildren(database, dirId, 0, Integer.MAX_VALUE);
        while (children.hasNext()) {
            
            FileMetadata metadata = children.next();
            files.add(metadata);
            
            if (recursive && metadata.isDirectory())
                getNestedFiles(files, database, metadata.getId(), recursive);
            
        }
        
        children.destroy();
    }
    
    public static long getRootParentId(DatabaseRO database) throws BabuDBException {
        
        ResultSet<byte[], byte[]> it = database.prefixLookup(BabuDBStorageManager.FILE_INDEX, null, null)
                .get();
        if (!it.hasNext())
            return -1;
        
        byte[] key = it.next().getKey();
        it.free();
        
        return ByteBuffer.wrap(key).getLong();
    }
    
    public static String getRootDirName(DatabaseRO database, long rootParentId) throws BabuDBException {
            
        byte[] rootParentIdBytes = ByteBuffer.wrap(new byte[8]).putLong(rootParentId).array();
        
        ResultSet<byte[], byte[]> it = database.prefixLookup(BabuDBStorageManager.FILE_INDEX,
            rootParentIdBytes, null).get();
        if (!it.hasNext())
            return null;
        
        byte[] key = it.next().getKey();
        it.free();
        
        return new String(key, 8, key.length - 9);
    }
    
}
