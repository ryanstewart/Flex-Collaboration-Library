/*
Copyright (c) 2009 Ryan Stewart
http://blog.digitalbackcountry.com

Special Thanks to the AFCS Team.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/


package afcs.collections
{
	import com.adobe.rtc.events.CollectionNodeEvent;
	import com.adobe.rtc.messaging.MessageItem;
	import com.adobe.rtc.messaging.NodeConfiguration;
	import com.adobe.rtc.session.ConnectSession;
	import com.adobe.rtc.sharedModel.CollectionNode;
	
	import mx.collections.ArrayCollection;
	import mx.utils.UIDUtil;
	
	/**
	 * This class is meant to map directly to a single ArrayCollection.
	 * The CollectionNode can have a single node which contains the 
	 * information in the ArrayCollection. Any changes to the array will
	 * change the specific node.
	 * 
	 * Multiple nodes should be added later.
	 **/
	public class SharedArrayCollection extends ArrayCollection
	{	
		[Event(name="sharedCollectionChange",type="com.adobe.rtc.events.CollectionNodeEvent")]
		
		protected var _collectionNode:CollectionNode;
		protected var _nodeConfig:NodeConfiguration;
		protected var _myUserID:String;
		
		protected static var NODE_NAME:String = "nodeItems";
		protected static var ID_FIELD:String = "itemID";
		
		public function SharedArrayCollection(source:Array=null)
		{
			super(source);
		}
		
		public function subscribe(sharedID:String, nodeConfig:NodeConfiguration=null):void
		{
			if( nodeConfig == null )
			{
				_nodeConfig = new NodeConfiguration();
				// Does this have to be manual? Should we support all storage schemes?
				_nodeConfig.itemStorageScheme = NodeConfiguration.STORAGE_SCHEME_MANUAL;
			} else {
				_nodeConfig = nodeConfig;
			}
			
			_myUserID = ConnectSession.primarySession.userManager.myUserID;
			
			_collectionNode = new CollectionNode();
			_collectionNode.sharedID = sharedID;
			_collectionNode.subscribe();
			_collectionNode.addEventListener(CollectionNodeEvent.SYNCHRONIZATION_CHANGE,onSyncChange);
			_collectionNode.addEventListener(CollectionNodeEvent.ITEM_RECEIVE,onItemReceive);
			_collectionNode.addEventListener(CollectionNodeEvent.ITEM_RETRACT,onItemRetract);
			_collectionNode.addEventListener(CollectionNodeEvent.NODE_DELETE,onNodeDelete);
		}

		/**
		 * ArrayCollection overridden functions
		 **/
		/**
		 * We override the array functions and have them only handle the 
		 * creation/deletion of messages on the collection node. We'll update
		 * the actuall array in the event handler classes of the CollectionNode
		 * to make sure that both server and client are updated before committing
		 * the change.
		 **/
		
		override public function addItem(item:Object) : void
		{
			var msg:MessageItem = new MessageItem(NODE_NAME,item,UIDUtil.createUID());
			_collectionNode.publishItem(msg);
		}
		
		// I need to look at how this is implemented on the actual ArrayCollection class
		// Do I fill in whitespace/overwrite? 
		override public function addItemAt(item:Object, index:int) : void
		{
			//var oldObj:Object = getItemAt(index);
			
		}

		override public function removeAll() : void
		{
			_collectionNode.removeNode(NODE_NAME);
		}
		
		override public function removeItemAt(index:int) : Object
		{
			_collectionNode.retractItem(NODE_NAME,this.source[index].itemID);
			return getItemAt(index);
		}
		
		override public function setItemAt(item:Object, index:int) : Object
		{
			var objOldItem:Object = getItemAt(index);
			var msg:MessageItem = new MessageItem(NODE_NAME,item,this.source[index].itemID);
			_collectionNode.publishItem(msg,true);
			
			return objOldItem;
		}
		
		/**
		*CollectionNode-specific event handlers
		 **/
		
		protected function onSyncChange(event:CollectionNodeEvent):void
		{
			//Not sure if anything needs to happen here.
		}
		
		protected function onItemReceive(event:CollectionNodeEvent):void
		{
			// How can we make sure that the server has the same order as the client?
			var tempObj:Object = new Object();
				tempObj.itemID = event.item.itemID;
				tempObj.content = event.item.body;
				
			if(!_collectionNode.isSynchronized)
			{
				this.source.push(tempObj);
			} else {
				// I feel like this is a messy way to do this. Need to revisit.
				var len:int = this.length;
				var isOld:Boolean = false;
				for(var i:int=0; i<len; i++)
				{
					if (this.source[i].itemID == tempObj.itemID)
					{
						//we have an old item that needs to be updated
						this.source[i].content = tempObj.content;
						isOld = true;
					} 
				}
				if( !isOld )
				{
					// we have a new item that we need to add
					this.source.push(tempObj);	
				}
			}
			dispatchEvent(event);
		}
		
		protected function onItemRetract(event:CollectionNodeEvent):void
		{
			var tempObj:Object = new Object();
			tempObj.itemID = event.item.itemID;
			tempObj.content = event.item.body;
			
			var len:int = this.length;
			for(var i:int=0; i<len; i++)
			{
				if (this.source[i].itemID == tempObj.itemID)
				{
					this.removeItemAt(i);
				} 
			}
		}
		
		protected function onNodeDelete(event:CollectionNodeEvent):void
		{
			// When we delete the node, we just create a blank array.
			this.source = new Array();
		}
		
		// Helper functions
		protected function getUniqueID(item:Object):String
		{
			return 'test';
		}
	}
}