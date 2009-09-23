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
	import mx.core.IUID;
	
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
		protected var _collectionNode:CollectionNode;
		protected var _nodeConfig:NodeConfiguration;
		protected var _myUserID:String;
		
		protected static var NODE_NAME:String = "nodeItems";
		
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
		}
		
		// ArrayCollection overridden functions
		/**
		 * We override the array functions and have them only handle the 
		 * creation/deletion of messages on the collection node. We'll update
		 * the actuall array in the event handler classes of the CollectionNode
		 * to make sure that both server and client are updated before committing
		 * the change.
		 **/
		
		override public function addItem(item:Object) : void
		{
			var msg:MessageItem = new MessageItem(NODE_NAME,item,IUID(item).uid);
			_collectionNode.publishItem(msg);
		}
		
		override public function addItemAt(item:Object, index:int) : void
		{
			
		}
		
		override public function contains(item:Object) : Boolean
		{
			return true;	
		}
		
		override public function removeAll() : void
		{
			
		}
		
		override public function removeItemAt(index:int) : Object
		{
			return new Object();
		}
		
		override public function setItemAt(item:Object, index:int) : Object
		{
			return new Object();
		}
		
		// CollectionNode-specific event handlers
		
		protected function onSyncChange(event:CollectionNodeEvent):void
		{
			
		}
		
		protected function onItemReceive(event:CollectionNodeEvent):void
		{
			
		}
		
		protected function onItemRetract(event:CollectionNodeEvent):void
		{
			
		}
		
		// Helper functions
		protected function getUniqueID(item:Object):void
		{
			
		}
	}
}