/*
 * Copyright (c) 2008-2011 by Jan Stender,
 *               Zuse Institute Berlin
 *
 * Licensed under the BSD License, see LICENSE file for details.
 *
 */

package org.xtreemfs.mrc.database;

/**
 * This interface defines how volume-related metadata is accessed.
 * 
 * XtreemFS file system content is arranged in volumes, with each volume having
 * its own directory tree. A volume has a globally unique name and id.
 * 
 * A volume holds different policies. The OSD policy determines which OSDs may
 * by default be allocated to files. The behavior of this policy may depend on
 * the policy's arguments, which are represented by an opaque string. The access
 * control policy defines the circumstances under which users are allowed to
 * access the volume.
 * 
 * @author stender
 * 
 */
public interface VolumeInfo {
    
    /**
     * Returns the volume's ID
     * 
     * @return the volume's ID
     */
    public String getId();
    
    /**
     * Returns the volume's name.
     * 
     * @return the volume's name
     */
    public String getName();
    
    /**
     * Returns the volume's OSD selection policy.
     * 
     * @return the volume's OSD selection policy
     */
    public short[] getOsdPolicy();
    
    /**
     * Returns the volume's replica selection policy.
     * 
     * @return the volume's replica selection policy
     */
    public short[] getReplicaPolicy();
    
    /**
     * Returns the volume's access control policy ID.
     * 
     * @return the volume's access control policy ID.
     */
    public short getAcPolicyId();
    
    /**
     * Returns the current approximate size of all files in the volume in bytes.
     * 
     * @return the volume's approximate size
     */
    public long getVolumeSize() throws DatabaseException;
    
    /**
     * Returns the volume's quota in bytes.
     * 
     * @return the volume's quota in bytes
     */
    public long getVolumeQuota() throws DatabaseException;
    /**
     * Returns the number of files currently stored in the volume.
     * 
     * @return the number of files
     */
    public long getNumFiles() throws DatabaseException;
    
    /**
     * Returns the number of directories currently stored in the volume.
     * 
     * @return the number of directories
     */
    public long getNumDirs() throws DatabaseException;
    
    /**
     * Checks whether this volume refers to a snapshot.
     * 
     * @return <code>true</code>, if the volume refers to a snapshot,
     *         <code>false</code>, otherwise
     */
    public boolean isSnapVolume() throws DatabaseException;
    
    /**
     * Checks whether snapshots are allowed for this volume.
     * 
     * @return <code>true</code>, if the volume allows snapshots,
     *         <code>false</code>, otherwise
     */
    public boolean isSnapshotsEnabled() throws DatabaseException;
    
    /**
     * Returns the time at which the volume was created in milliseconds since 1970
     * 
     * @return the creation time stamp in milliseconds since 1970
     */
    public long getCreationTime() throws DatabaseException;
    
    /**
     * Sets the volume's OSD selection policy.
     * 
     * @param osdPolicy
     *            the new OSD selection policy for the volume
     */
    public void setOsdPolicy(short[] osdPolicy, AtomicDBUpdate update) throws DatabaseException;
    
    /**
     * Sets the volume's replica selection policy.
     * 
     * @param replicaPolicy
     *            the new replica selection policy for the volume
     */
    public void setReplicaPolicy(short[] replicaPolicy, AtomicDBUpdate update) throws DatabaseException;
    
    /**
     * Specifies whether snapshots may be created on this volume.
     * 
     * @param allowSnaps
     *            a flag specifying whether snapshots may be created
     */
    public void setAllowSnaps(boolean allowSnaps, AtomicDBUpdate update) throws DatabaseException;

    /**
     * Set the volume's quota.
     * 
     * @param quota
     *            quota in bytes
     * @throws DatabaseException
     */
    public void setVolumeQuota(long quota, AtomicDBUpdate update) throws DatabaseException;

    /**
     * Adds <code>diff</code> to the current volume size.
     * 
     * @param diff
     *            the difference between the new and the old volume size
     */
    public void updateVolumeSize(long diff, AtomicDBUpdate update) throws DatabaseException;
    
}