package  
{
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
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
		// set to true for debugging purposes
		private var debug:Boolean = false;
		
		private var overlay:TouchSprite = new TouchSprite();
		private var cam:Camera = new Camera();
		private var model_container:TouchContainer3D;
		//private var view:View3D;
		
		// Main container for moving whole model
		private var main:ObjectContainer3D;

		// models for complex radial translation
		private var outer_shell_yellow:Model;
		private var outer_shell_red:Model;
		private var pipes:Model;
		private var muons2left:Model;
		private var muons2right:Model;
		private var innerShell:Model;
		private var innerShellBlue:Model;
		private var inner_inner_shell:Model;
		
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

		// array of models for rotating each one independently
		private var containers:Array;

		// UI elements for guidance
		private var point_dial:Container = document.getElementById("point_dial");
		private var directionalArrows:Container = document.getElementById("directionalArrows");

		// Elements for info screen 
		private var info_overlay:Image = document.getElementById("info_overlay");
		private var info_screen:Container = document.getElementById("info_screen");
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
			//view = document.getElementById("main_view");
			stage.addChild(new AwayStats());
			
			// get model
			model_container = document.getElementById("model_container");

			//Get Camera from scene
			cam = document.getElementById("main_cam");

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
			
			// get elements for complex transitions
			outer_shell_yellow = document.getElementById("outer_shell_yellow");
			outer_shell_red = document.getElementById("outer_shell_red");
			pipes = document.getElementById("pipes");
			muons2left = document.getElementById("muons2left");
			muons2right = document.getElementById("muons2right");
			innerShell = document.getElementById("innerShell");
			innerShellBlue = document.getElementById("innerShellBlue");
			inner_inner_shell = document.getElementById("inner_inner_shell");
			// grab all of the cml popup elements
			popups = document.getElementsByTagName(ModelPopup);
			
			// grab all of the cml model elements
			models = document.getElementsByTagName(Model);
			
			// grab all of the 3D container elements
			containers = document.getElementsByTagName(ObjectContainer3D);
			
			outer_shell_yellow.vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			outer_shell_yellow.vto.addEventListener(GWGestureEvent.SCALE, onScale);
			outer_shell_yellow.vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			outer_shell_red.vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			outer_shell_red.vto.addEventListener(GWGestureEvent.SCALE, onScale);
			outer_shell_red.vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			pipes.vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			pipes.vto.addEventListener(GWGestureEvent.SCALE, onScale);
			pipes.vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			document.getElementById("left_tube").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("left_tube").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("left_tube").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
	
			document.getElementById("right_tube").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("right_tube").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("right_tube").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			muons2left.vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			muons2left.vto.addEventListener(GWGestureEvent.SCALE, onScale);
			muons2left.vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			muons2right.vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			muons2right.vto.addEventListener(GWGestureEvent.SCALE, onScale);
			muons2right.vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
		
			innerShell.vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			innerShell.vto.addEventListener(GWGestureEvent.SCALE, onScale);
			innerShell.vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			innerShellBlue.vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			innerShellBlue.vto.addEventListener(GWGestureEvent.SCALE, onScale);
			innerShellBlue.vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);

			document.getElementById("gearsLeft").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("gearsLeft").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("gearsLeft").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
	
			document.getElementById("gearsRight").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("gearsRight").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("gearsRight").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);

			document.getElementById("inner_inner_shell").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
			document.getElementById("inner_inner_shell").vto.addEventListener(GWGestureEvent.SCALE, onScale);
			document.getElementById("inner_inner_shell").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);
			
			/*document.getElementById("engine").vto.addEventListener(GWGestureEvent.DRAG, onModelDrag);
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
			document.getElementById("front_fan").vto.addEventListener(GWGestureEvent.TAP, onHotspotTap);*/
				
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
				var displacement_8:Number = e.value.rotate_dthetaZ * 8;
				var displacement_7:Number = e.value.rotate_dthetaZ * 7;
				var displacement_6:Number = e.value.rotate_dthetaZ * 6;
				var displacement_5:Number = e.value.rotate_dthetaZ * 5;
				var displacement_4:Number = e.value.rotate_dthetaZ * 4;
				var displacement_3:Number = e.value.rotate_dthetaZ * 3;
				var displacement_2:Number = e.value.rotate_dthetaZ * 2;
				var displacement_1:Number = e.value.rotate_dthetaZ * 1;
				var curr_position:Vector3D = main.scenePosition;
				
				for (var i:int = 0; i < containers.length; i++)
				{
					var final_position:Number = 0;
					
					if (containers[i].id == "container04") 
					{
						containers[i].moveLeft(displacement_3);
						final_position = containers[i].x;
					    if (final_position > 0) containers[i].x = 0;
					}
					else if (containers[i].id == "container05") 
					{
						containers[i].moveRight(displacement_3);
						final_position = containers[i].x;
					    if (final_position < 0) containers[i].x = 0;
					}
					else if (containers[i].id == "container07") 
					{
						containers[i].moveLeft(displacement_2);
						final_position = containers[i].x;
					    if (final_position > 0) containers[i].x = 0;
					}
					else if (containers[i].id == "container08") 
					{
						containers[i].moveRight(displacement_2);
						final_position = containers[i].x;
					    if (final_position < 0) containers[i].x = 0;
					}
					else if (containers[i].id == "container11") 
					{
						containers[i].moveLeft(displacement_1);	
						final_position = containers[i].x;2
					    if (final_position > 0) containers[i].x = 0;
					}
					else if (containers[i].id == "container12") 
					{
						containers[i].moveRight(displacement_1);
						final_position = containers[i].x;
					    if (final_position < 0) containers[i].x = 0;
					}
					/*else if (containers[i].id == "container06") 
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
					}*/
				}
				
				explodeRadialModelYZ(outer_shell_yellow, displacement_5);
				explodeRadialModelYZ(outer_shell_red, displacement_4);
				explodeRadialModelYZ(pipes, displacement_4);
				explodeRadialModelYZ(muons2left, displacement_3);
				explodeRadialModelYZ(muons2right, displacement_3);
				explodeRadialModelYZ(innerShell, displacement_3);
				explodeRadialModelYZ(innerShellBlue, displacement_2);
				explodeRadialModelYZ(inner_inner_shell, displacement_1);
				
				// re-orient the containers back to their original orientation
				// negates viewer interaction and rotation
				if (e.value.rotate_dthetaZ < -10.0)
				{
					reOrderContainers();
					implodeRadialModelYZ(outer_shell_yellow);
					implodeRadialModelYZ(outer_shell_red);
					implodeRadialModelYZ(pipes);
					implodeRadialModelYZ(muons2left);
					implodeRadialModelYZ(muons2right);
					implodeRadialModelYZ(innerShell);
					implodeRadialModelYZ(innerShellBlue);
					implodeRadialModelYZ(inner_inner_shell);
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
			for (var i:int = 0; i < containers.length; i++) 
			{
				
				if (containers[i].id != "main" && containers[i].id != "main_cam" && containers[i].id != "light-1") 
				{
					trace("Container = " + containers[i].id  + ", z location = ", + containers[i].z);
					TweenLite.to(containers[i], 3, { rotationX:0 } );
					TweenLite.to(containers[i], 3, { rotationY:0 } );
					TweenLite.to(containers[i], 3, { rotationZ:0 } );
					TweenLite.to(containers[i], 3, { x:0 } );
					TweenLite.to(containers[i], 3, { y:0 } );
					TweenLite.to(containers[i], 1, { z:0 } );
				}
			}
		}	
		
		private function implodeRadialModelYZ(whole_model:Model):void 
		{
			for (var i:int = 0; i < whole_model.numChildren; i++) 
			{
				// return all radial elements to the center
				TweenLite.to(whole_model.getChildAt(i), 3, { y:0 } );
				TweenLite.to(whole_model.getChildAt(i), 3, { z:0 } );
			}
		}	
		
		private function explodeRadialModelYZ(whole_model:Model, displacement:Number):void 
		{
			// starting point of first radial element (at 180 for this demo)
			// set the starting angle of your index[0] element
			// e.g: if you first radial element is straight up, set to 90
			var totalRotation:Number = 180.0;
			
			// gets the total number of elements
			var degree:int = whole_model.numChildren;
			
			// sets the degree amount between elements
			var spacer:Number = 360 / degree;
			
			// amount to change on eah call (based on user input rotation)
			var newZ:Number = 0;
			var newY:Number = 0;
			
			// loop through each of the elements in the model
			for (var i:int = 0; i < degree; i++) 
			{
				// swith to radians for cosine and sine calculations
				var radianValue = radians(totalRotation);
				
				newZ = (displacement * ((-1)*Math.cos(radianValue)));
				newY = (displacement * Math.sin(radianValue));
				
				if (debug)
				{
				  trace(" ");
				  trace("Sin totalRotation = " + Math.sin(radianValue));
				  trace("Cos totalRotation = " + Math.cos(radianValue));
				  trace("total rotation = " + totalRotation);
				  trace("New z = " + newZ);
				  trace("New y = " + newY);
				  trace(whole_model.getChildAt(i).id);
				  trace(whole_model.getChildAt(i).name);
				}
				
				whole_model.getChildAt(i).y += newY;
				whole_model.getChildAt(i).z += newZ;
				
				// limit objects to starting vertical position upon reverse motion
				if (totalRotation < 180 && whole_model.getChildAt(i).y < 0) whole_model.getChildAt(i).y = 0;
				if (totalRotation > 180 && whole_model.getChildAt(i).y > 0) whole_model.getChildAt(i).y = 0;
				
				// limit objects to starting horizontal position upon reverse motion
				if ((totalRotation < 90 || totalRotation > 270) && whole_model.getChildAt(i).z > 0) whole_model.getChildAt(i).z = 0;
				if (totalRotation > 90 && totalRotation < 270 && whole_model.getChildAt(i).z < 0) whole_model.getChildAt(i).z = 0;

				// decrease the degrees as you move through elements
				// for this demo, elements were arranged in increasing fashion going clockwise, 
				// thus the negative, counterclockwise would be positive
				totalRotation -= spacer;
				if (totalRotation <= 0) totalRotation = 360;
			}
		}
	
		/*private function explodeRadialModelYX(whole_model:Model, displacement:Number):void 
		{
			// starting point of first radial element (at 180 for this demo)
			// set the starting angle of your index[0] element
			// e.g: if you first radial element is straight up, set to 90
			var totalRotation:Number = 180.0;
			
			// gets the total number of elements
			var degree:int = whole_model.numChildren;
			
			// sets the degree amount between elements
			var spacer:Number = 360 / degree;
			
			// amount to change on eah call (based on user input rotation)
			var newZ:Number = 0;
			var newY:Number = 0;
			
			// loop through each of the elements in the model
			for (var i:int = 0; i < degree; i++) 
			{
				// swith to radians for cosine and sine calculations
				var radianValue = radians(totalRotation);
				
				newZ = (displacement * ((-1)*Math.cos(radianValue)));
				newX = (displacement * Math.sin(radianValue));
				
				if (debug)
				{
				  trace(" ");
				  trace("Sin totalRotation = " + Math.sin(radianValue));
				  trace("Cos totalRotation = " + Math.cos(radianValue));
				  trace("total rotation = " + totalRotation);
				  trace("New x = " + newX);
				  trace("New y = " + newY);
				  trace(whole_model.getChildAt(i).id);
				  trace(whole_model.getChildAt(i).name);
				}
				
				whole_model.getChildAt(i).y += newY;
				whole_model.getChildAt(i).x += newX;
				
				// limit objects to starting vertical position upon reverse motion
				if (totalRotation < 180 && whole_model.getChildAt(i).y < 0) whole_model.getChildAt(i).y = 0;
				if (totalRotation > 180 && whole_model.getChildAt(i).y > 0) whole_model.getChildAt(i).y = 0;
				
				// limit objects to starting horizontal position upon reverse motion
				if ((totalRotation < 90 || totalRotation > 270) && whole_model.getChildAt(i).x > 0) whole_model.getChildAt(i).x = 0;
				if (totalRotation > 90 && totalRotation < 270 && whole_model.getChildAt(i).x < 0) whole_model.getChildAt(i).x = 0;

				// decrease the degrees as you move through elements
				// for this demo, elements were arranged in increasing fashion going clockwise, 
				// thus the negative, counterclockwise would be positive
				totalRotation -= spacer;
				if (totalRotation <= 0) totalRotation = 360;
			}
		}*/
		
		private function radians(degrees:Number):Number
		{
			return degrees * Math.PI / 180;
		}
	}		
}