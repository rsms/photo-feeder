/*
 * PhotoFeeder is the legal property of its developers.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. You should have received a copy 
 * of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 59 Temple Place, 
 * Suite 330, Boston, MA 02111-1307 USA
 */
#import "PFQueue.h"

@implementation PFQueue


// Initialize queue with capacity for x num items.
- (id) initWithCapacity:(int)capacity
{
  _capacity = capacity;
  _count = 0;
  _putIndex = 0;
  _pullIndex = 0;
  _buckets = (id *)malloc(sizeof(id)*capacity);
  
  if(_buckets == NULL)
    [NSException raise:@"PFQueue" format:@"Out of memory - malloc(%d*%d) failed", sizeof(id), capacity];
  
  if(!memset(_buckets, 0, sizeof(id)*capacity)) {
    free(_buckets);
    [NSException raise:@"PFQueue" format:@"Memory failure - memset(%p, 0, %d) failed", _buckets, sizeof(id)*capacity];
  }
  
  _fullCL = [[NSConditionLock alloc] initWithCondition:FALSE];
  _emptyCL = [[NSConditionLock alloc] initWithCondition:TRUE];
  
  _putLock = [[NSRecursiveLock alloc] init];
  _takeLock = [[NSRecursiveLock alloc] init];
  _modLock = [[NSRecursiveLock alloc] init];
  
  return self;
}


- (void) dealloc
{
  [_fullCL release];
  [_emptyCL release];
  
  [_putLock release];
  [_takeLock release];
  [_modLock release];
  
  free(_buckets);
  
  [super dealloc];
}


- (int) count
{
  [_modLock lock];
  int cnt = _count;
  [_modLock unlock];
  return cnt;
}


// Adds the specified element to the tail of this queue, waiting if 
// necessary for space to become available.
- (void) put:(id)item
{
  // Make sure this is a isolated call in a critical section (reentrant)
  [_putLock lock];
  
  // First, wait and aquire empty lock (no matter if its empty)
  //[_emptyCL lock];
  
  // Wait until there is free space
  [_fullCL lockWhenCondition:FALSE];
  
  
  [_modLock lock];
  
  //DLog(@"PUT item on putIndex %d. putIndex is now %d", _putIndex, _putIndex+1);
  _buckets[_putIndex++] = [item retain];
  _count++;
  
  if(_putIndex == _capacity)
    _putIndex = 0;
  
  [_modLock unlock];
  
  // Check if the queue is full
  if(_putIndex == _pullIndex) {
    // Unlock and set full to TRUE
    [_fullCL unlockWithCondition:TRUE];
  }
  else {
    // Unlock and set full to FALSE
    [_fullCL unlockWithCondition:FALSE];
  }
  
  // Set condition
  [_emptyCL lock];
  [_emptyCL unlockWithCondition:FALSE];
  
  // End critical section
  [_putLock unlock];
}


// Adds the specified element to the tail of this queue if possible,
// returning immediately if this queue is full.
- (BOOL) offer:(id)item
{
  // Begin critical section
  [_putLock lock];
  
  // First, wait and aquire empty lock (no matter if its empty)
  //[_emptyCL lock];
  
  // Is full? (lock failed)
  if(![_fullCL tryLockWhenCondition:FALSE])
  {
    // Unlock, leaving condition unchanged
    //[_emptyCL unlock];
    
    // End critical section
    [_putLock unlock];
    
    return NO;
  }
  
  [_modLock lock];
  
  //DLog(@"PUT item on putIndex %d. putIndex is now %d", _putIndex, _putIndex+1);
  _buckets[_putIndex++] = [item retain];
  _count++;
  
  if(_putIndex == _capacity)
    _putIndex = 0;
  
  [_modLock unlock];
  
  
  // Check if the queue is full
  if(_putIndex == _pullIndex) {
    // Unlock and set full to TRUE
    [_fullCL unlockWithCondition:TRUE];
  }
  else {
    // Unlock and set full to FALSE
    [_fullCL unlockWithCondition:FALSE];
  }
  
  
  // Set empty to FALSE
  [_emptyCL lock];
  [_emptyCL unlockWithCondition:FALSE];
  
  // End critical section
  [_putLock unlock];
  
  return YES;
}


// Get the next element in queue, waiting if necessary for an element
// to become available.
- (id) take
{
  // Isolate call with a critical section
  [_takeLock lock];
  
  // Wait here until the queue is not empty
  [_emptyCL lockWhenCondition:FALSE];
  
  
  [_modLock lock];
  
  //DLog(@"TAKE item from pullIndex %d. pullIndex is now %d", _pullIndex, _pullIndex+1);
  id item = _buckets[_pullIndex];
  _buckets[_pullIndex++] = NULL;
  _count--;
  
  if(_pullIndex == _capacity)
    _pullIndex = 0;
  
  [_modLock unlock];
  
  // Set full to FALSE
  [_fullCL lock];
  [_fullCL unlockWithCondition:FALSE];
  
  // Check if the queue is empty
  if(_putIndex == _pullIndex) {
    // Unlock and set empty to TRUE
    [_emptyCL unlockWithCondition:TRUE];
  }
  else {
    // Unlock and set empty to FALSE
    [_emptyCL unlockWithCondition:FALSE];
  }
  
  // End critical section
  [_takeLock unlock];
  
  [item release];
  return item;
}


// Get the next element in queue if any, returning immediately
// if this queue is empty.
- (id) poll
{
  // Begin critical section
  [_takeLock lock];
  
  // If empty, rollback
  if(![_emptyCL tryLockWhenCondition:FALSE])
  {
    // End critical section
    [_takeLock unlock];
    
    return nil;
  }
  
  
  [_modLock lock];
  
  //DLog(@"TAKE item from pullIndex %d. pullIndex is now %d", _pullIndex, _pullIndex+1);
  id item = _buckets[_pullIndex];
  _buckets[_pullIndex++] = NULL;
  _count--;
  
  if(_pullIndex == _capacity)
    _pullIndex = 0;
  
  [_modLock unlock];
  
  
  // Set full to FALSE
  [_fullCL lock];
  [_fullCL unlockWithCondition:FALSE];
  
  // Check if the queue is empty
  if(_putIndex == _pullIndex) {
    // Unlock and set empty to TRUE
    [_emptyCL unlockWithCondition:TRUE];
  }
  else {
    // Unlock and set empty to FALSE
    [_emptyCL unlockWithCondition:FALSE];
  }
  
  // End critical section
  [_takeLock unlock];
  
  [item release];
  return item;
}


@end
