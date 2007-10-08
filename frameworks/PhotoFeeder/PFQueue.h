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

/**
 * A thread-safe, slective blocking FIFO queue - Firt in, First out.
 *
 * @version $Id: PFQueue.h 95 2007-01-16 23:25:00Z rasmus $
 * @author  Rasmus Andersson
 */
@interface PFQueue : NSObject
{
	@private
	int _capacity;
	int _count;
	int _putIndex;
	int _pullIndex;
	id* _buckets;
	
	NSRecursiveLock* _putLock;
	NSRecursiveLock* _takeLock;
	NSRecursiveLock* _modLock;
	
	NSConditionLock* _fullCL;
	NSConditionLock* _emptyCL;
}

/**
 * Initialize queue with capacity for x num items.
 *
 * @throws NSException "PFQueue" If out of memory or if memset failed
 */
- (id) initWithCapacity:(int)capacity;


/**
 * Number of elements currently in queue
 */
- (int) count;


/**
 * Adds the specified element to the tail of this queue if possible,
 * returning immediately if this queue is full.
 *
 * @param   Item to enqueue
 * @return  Was queued?
 * @see     put
 */
- (BOOL) offer:(id)item;


/**
 * Adds the specified element to the tail of this queue, waiting if
 * necessary for space to become available.
 *
 * @param   Item to enqueue
 * @see     offer
 */
- (void) put:(id)item;


/**
 * Get the next element in queue if any, returning immediately
 * if this queue is empty.
 *
 * @return  item or nil if queue was empty
 * @see     take
 */
- (id) poll;


/**
 * Get the next element in queue, waiting if necessary for an element
 * to become available.
 *
 * @return  item or nil if queue was empty
 * @see     poll
 */
- (id) take;

@end
