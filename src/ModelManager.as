package  
{
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.core.partition.SkyBoxNode;
	import away3d.primitives.SkyBox;
	import away3d.textures.BitmapTexture;
	import com.adobe.air.crypto.EncryptionKeyGenerator;
	import com.gestureworks.cml.away3d.elements.Camera;
	import away3d.entities.Mesh;
	import caurina.transitions.Tweener;	
	import com.gestureworks.away3d.TouchManager3D;
	import com.gestureworks.cml.away3d.elements.Container3D;
	import com.gestureworks.cml.away3d.elements.Model;
	import com.gestureworks.cml.away3d.elements.Scene;
	import com.gestureworks.cml.away3d.elements.TouchContainer3D;
	import com.gestureworks.cml.core.CMLAway3D;
	import com.gestureworks.cml.core.CMLParser;
	import com.gestureworks.cml.utils.document;
	import com.gestureworks.core.GestureWorks;
	import com.gestureworks.events.GWClusterEvent;
	import com.gestureworks.events.GWGestureEvent;
	import com.gestureworks.cml.elements.Image; 
	import com.gestureworks.cml.elements.Text;
	import com.gestureworks.cml.elements.Container;
	import com.gestureworks.core.TouchSprite;
	import flash.display.BitmapData;

	import com.greensock.plugins.ShortRotationPlugin;
	import com.greensock.plugins.TweenPlugin;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;

	import flash.geom.ColorTransform;
	import com.greensock.TweenLite;
	import com.greensock.plugins.*;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	/**
	* ...
	* @author John-Mark Collins	
	* * */
	
	public class ModelManager extends Sprite 
	{ 	
		private var overlay:TouchSprite = new TouchSprite();
		private var cam:Camera = new Camera();
		private var model_container:TouchContainer3D;
		
		private var main:ObjectContainer3D;

		private var engine:Model;
		private var rod:Model;
		private var rotor1:Model;
		private var engine_nose:Model;
		private var engine_tail:Model;
		
		private var minScale:Number = .25;
		private var maxScale:Number = 4;
	
		private var minExplosion:Number = -200;
		private var maxExplosion:Number = 200;

		private var maxRotationX:Number = 60;
		private var minRotationX:Number = -maxRotationX;
	
		// array of popups for each model piece
		private var popups:Array;
		
		// array of models for rotating each one independently
		private var models:Array;
		
		//sample independent 3D model explosion
		private var model:Model;
		
		// array of models for rotating each one independently
		private var containers:Array;

		// UI elements for guidance
		private var point_dial:Container = document.getElementById("point_dial");
		private var directionalArrows:Container = document.getElementById("directionalArrows");

		// Elements for info screen 
		private var info_overlay:Image = document.getElementById("info_overlay");
		private var info_screen = document.getElementById("info_screen");
		private var info_screen_exit:Image = document.getElementById("info_screen_icon");
		
		// State of the UI element for rotating dial rotation degree
		private var dialValue:Number = 0.0;
	
		// Timer for removing info screen 
		private var secTimer:Timer = new Timer(1000, 1);
	
		public function ModelManager() 
		{
			TweenPlugin.activate([ShortRotationPlugin]);
			super();
		}

		public function init():void 
		{
			// Construct main screen and gesture enabling
			
			// get model
			model_container = document.getElementById("model_container");
			model = document.getElementById("front_fan");
			//Get Camera from scene
			cam = document.getElementById("main_cam");
			/*cam.x = -400;
			cam.y = 200;
			cam.z = -300;	
			cam.lookAt( new Vector3D(0, 0, 0) );*/

			// add touch overlay for fiducial gestures
			stage.addChild(overlay);

			// Add model to 3D scene 
			overlay.addChild(model_container);
		
			// add child gestures
			overlay.mouseChildren = true;
			overlay.clusterBubbling = true;
			
			// add events 
			overlay.gestureList = { "n-tap": true,
									"n-rotate-3d": true,
									"n-drag": true, 
									"n-scale-3d": true };

		
			main = document.getElementById("main");
			
			engine = document.getElementById("engine");
			/*rod = document.getElementById("rod");
			rotor1 = document.getElementById("rotor1");
			engine_nose = document.getElementById("engine_nose");
			engine_tail = document.getElementById("engine_tail");*/
				
			// grab all of the cml popup elements
			popups = document.getElementsByTagName(ModelPopup);
			
			// grab all of the cml model elements
			models = document.getElementsByTagName(Model);
			
			// grab all of the 3D container elements
			containers = document.getElementsByTagName(ObjectContainer3D);
			
			document.getElementById("back_shell_left").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("back_shell_left").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("back_shell_left").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			document.getElementById("back_shell_right").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("back_shell_right").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("back_shell_right").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			document.getElementById("central_shell_left").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("central_shell_left").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("central_shell_left").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			document.getElementById("central_shell_right").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("central_shell_right").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("central_shell_right").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			document.getElementById("inner_shell_left").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("inner_shell_left").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("inner_shell_left").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
		
			document.getElementById("inner_shell_right").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("inner_shell_right").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("inner_shell_right").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			document.getElementById("outer_shell_left").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("outer_shell_left").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("outer_shell_left").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);

			document.getElementById("outer_shell_right").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("outer_shell_right").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("outer_shell_right").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
	
			document.getElementById("small_shell_top").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("small_shell_top").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("small_shell_top").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);

			document.getElementById("small_shell_bottom").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("small_shell_bottom").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("small_shell_bottom").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			document.getElementById("engine").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("engine").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			
			document.getElementById("engine_nose").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("engine_nose").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			
			document.getElementById("engine_tail").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("engine_tail").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			
			document.getElementById("rod").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("rod").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			
			document.getElementById("rotor1").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("rotor1").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			
			document.getElementById("front_fan").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("front_fan").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("front_fan").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
				
			//mainScreen.addEventListener(GWGestureEvent.TAP, onTap);
			overlay.addEventListener(GWGestureEvent.ROTATE, onRotate);
			overlay.addEventListener(GWGestureEvent.DRAG, onDrag);
			overlay.addEventListener(GWGestureEvent.SCALE, onScale);
			
			// Add listeners for infor screen and exit buttons
			document.getElementById("info_overlay").addEventListener(GWGestureEvent.TAP, onInfoTap);
			document.getElementById("info_screen_icon").addEventListener(GWGestureEvent.TAP, onInfoTapExit);
			
			// add event listener to every frame for animations
			this.stage.addEventListener( Event.ENTER_FRAME, this._onUpdate );
		
			// add listener for completion of timer event
			secTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerFunction);
		
			// create transparency for info screen and initial UI elements
			info_screen.alpha = 0;
			point_dial.alpha = 0;
			directionalArrows.alpha = 0;
			
			// Add UI elements
			overlay.addChild(info_overlay);
			overlay.addChild(point_dial);
			overlay.addChild(directionalArrows);
			
			// Set initial state of UI elements
			fade(point_dial, "out");
			fade(directionalArrows, "out");
		}
		
		// our update function
		private function _onUpdate( e:Event ):void
		{
			// call your function here
			dialValue = dialValue + 4.0;
			if (dialValue == 360) dialValue = 0.0;

			// up our count
			point_dial.rotationZ = dialValue;

			// if it's 60, then stop
			//if( this.m_currCount >= 60 )
			//this.stage.removeEventListener( Event.ENTER_FRAME, this._onUpdate );
		}
		
		private function onModelDrag(e:GWGestureEvent):void 
		{
			var current_model:Model = document.getElementById(e.target.id);
			var current_container:ObjectContainer3D = current_model.parent;
			
			if (e.value.n == 1)
			{
			  var val:Number = current_container.rotationX + e.value.drag_dy * .25;
			
			  if (val < minRotationX) val = minRotationX;
			  else if (val > maxRotationX) val = maxRotationX;
				
			  current_container.rotationY -= e.value.drag_dx * .5;
			  current_container.rotationX = val;
			}
		}
		
		private function onRotate(e:GWGestureEvent):void 
		{
			if (e.value.n == 5)
			{
				var fastest_displacement:Number = e.value.rotate_dthetaZ * 5;
				var fast_displacement:Number = e.value.rotate_dthetaZ * 4;
				var slow_displacement:Number = e.value.rotate_dthetaZ * 2;
				var slowest_displacement:Number = e.value.rotate_dthetaZ * 1;
				var curr_position:Vector3D = main.scenePosition;
				
				for (var i:int = 0; i < containers.length; i++)
				{
					var final_position:Number = 0;
					
					if (containers[i].id == "container01") 
					{
						containers[i].moveForward(slowest_displacement);
						final_position = containers[i].z;
					    if (final_position < 0) containers[i].z = 0;
					}
					else if (containers[i].id == "container02") 
					{
						containers[i].moveBackward(slowest_displacement);
						final_position = containers[i].z;
					    if (final_position > 0) containers[i].z = 0;
					}
					else if (containers[i].id == "container03") 
					{
						containers[i].moveForward(slow_displacement);
						final_position = containers[i].z;
					    if (final_position < 0) containers[i].z = 0;
					}
					else if (containers[i].id == "container04") 
					{
						containers[i].moveBackward(slow_displacement);	
						final_position = containers[i].z;
					    if (final_position > 0) containers[i].z = 0;
					}
					else if (containers[i].id == "container05") 
					{
						containers[i].moveForward(fast_displacement);
						final_position = containers[i].z;
					    if (final_position < 0) containers[i].z = 0;
					}
					else if (containers[i].id == "container06") 
					{
						containers[i].moveBackward(fast_displacement);
						final_position = containers[i].z;
					    if (final_position > 0) containers[i].z = 0;
					}
					else if (containers[i].id == "container07") 
					{
						containers[i].moveBackward(fastest_displacement);
						final_position = containers[i].z;
					    if (final_position > 0) containers[i].z = 0;
					}
					else if (containers[i].id == "container08") 
					{
						containers[i].moveForward(fastest_displacement);
						final_position = containers[i].z;
					    if (final_position < 0) containers[i].z = 0;
					}
					else if (containers[i].id == "container10") 
					{
						containers[i].moveLeft(fastest_displacement);
						final_position = containers[i].x;
					    if (final_position > 0) containers[i].x = 0;
					}
					else if (containers[i].id == "container11") 
					{
						containers[i].moveRight(fast_displacement);
						final_position = containers[i].x;
						if (final_position < 0) containers[i].x = 0;
					}
					else if (containers[i].id == "container12") 
					{
						containers[i].moveRight(slow_displacement);	
						final_position = containers[i].x;
						if (final_position < 0) containers[i].x = 0;
					}
					else if (containers[i].id == "container13") 
					{
						containers[i].moveLeft(slow_displacement);
						final_position = containers[i].x;
						if (final_position > 0) containers[i].x = 0;
					}
					else if (containers[i].id == "container19") 
					{
						containers[i].moveLeft(fast_displacement);
						final_position = containers[i].x;
						if (final_position > 0) containers[i].x = 0;
					}
				}
				
				// re-orient the containers back to their original orientation
				// negates viewer interaction and rotation
				if (e.value.rotate_dthetaZ < -10.0)
				{
					reOrderContainers();
				}

				// draw rotating dial animation
				var x:int = e.value.localX;
				var y:int = e.value.localY;
				point_dial.x = x;
				point_dial.y = y;
			
				fade(point_dial, "in");

			}
			else fade(point_dial, "out");
		}
		
		private function onDrag(e:GWGestureEvent):void
		{
			if (e.value.n == 3)
			{
				var x:int = e.value.localX;
				var y:int = e.value.localY;
				directionalArrows.x = x;
				directionalArrows.y = y;
				fade(directionalArrows, "in");
				
				var val:Number = main.rotationX + e.value.drag_dy * .25;
			
				if (val < minRotationX) val = minRotationX;
				else if (val > maxRotationX) val = maxRotationX;
				
				main.rotationY -= e.value.drag_dx * .5;
				main.rotationX = val;
			}
			
			if (e.value.n == 8)
			{
				var val:Number = cam.rotationX + e.value.drag_dy * .25;
			
				if (val < minRotationX) val = minRotationX;
				else if (val > maxRotationX) val = maxRotationX;
				
				cam.rotationY -= e.value.drag_dx * .5;
				cam.rotationX = val;
			}
				
			else fade(directionalArrows, "out");
		}
		
		private function onScale(e:GWGestureEvent):void
		{
			var val:Number = main.scaleX + e.value.scale_dsx * .75;
			if (val < minScale) val = minScale;
			else if (val > maxScale) val = maxScale;
			
			// scale the entire model, not individual pieces
			main.scaleX = val;
			main.scaleY = val;
			main.scaleZ = val;
		}

		private function onHotspotTap(e:GWGestureEvent):void 
		{
			var popup:ModelPopup = document.getElementById(e.target.vto.name);
			for (var i:int = 0; i < popups.length; i++) 
			{
				if (popups[i].visible && popups[i] != popup) 
				{
					popups[i].tweenOut();
				}
			}
			if (!popup.visible) 
			{
				popup.x = this.mouseX;
				popup.y = this.mouseY;

				popup.tweenIn(); 
			}
			else popup.tweenOut();	
		}
		
		private function timerFunction(e:Event = null):void
		{
			if (overlay.contains(info_screen))  overlay.removeChild(info_screen);
		}
		
		private function onInfoTap(e:GWGestureEvent):void
		{
			info_screen.alpha = 0;
			overlay.addChild(info_screen);
			if (info_screen.visible == false) info_screen.visible = true;
			fade(info_screen, "in");
		}
			
		private function onInfoTapExit(e:GWGestureEvent):void
		{
			fade(info_screen, "out");
			secTimer.start();
		}
					
		private function fade(item: Container, direction:String):void 
		{
			if (direction == "in")
			{
				if (item.visible == false) item.visible = true;
				TweenLite.to(item, 1, { alpha:1} );
			}
			else
			{
				TweenLite.to(item, 1, { alpha:0 } );	
				if (item.visible == false) item.visible = true;
			}
		}
				
		private function reOrderContainers():void
		{
			//var popup:ModelPopup = document.getElementById(e.target.vto.name);
			
			
			// TODO: Issues with independent models rotating properly
			for (var i:int = 0; i < containers.length; i++) 
			{
				
				if (containers[i].id != "main") 
				{
					trace("Container = " + containers[i].id  + ", z location = ", + containers[i].z);
					TweenLite.to(containers[i], 3, { rotationX:0 } );
					TweenLite.to(containers[i], 3, { rotationY:0 } );
					TweenLite.to(containers[i], 3, { rotationZ:0 } );
					TweenLite.to(containers[i], 3, { x:0 } );
					TweenLite.to(containers[i], 3, { y:0 } );
					
					// Issue with z-axis re-orientation...
					//TweenLite.to(containers[i], 1, { z:0 } );
				}
			}
		}	
		
		private function explodeComplexModel(whole_model: Container):void 
		{
			for (var i:int = 0; i < whole_model.length; i++) 
			{
				
			}
		}
	}		
}