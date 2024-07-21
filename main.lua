require "import"
import "init"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.support.v4.widget.*"
import "android.graphics.*"
import "android.view.animation.*"
import "layout"
import "memberitem"
import "android.graphics.Paint"
import "android.graphics.Typeface"




activity.setTheme(R.AndLua16);
activity.ActionBar.hide();
activity.overridePendingTransition(android.R.anim.fade_in,android.R.anim.fade_out);
if Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP then
  activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS).setStatusBarColor(0xFFFFFFFF);
  activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS).setNavigationBarColor(0xFFFFFFFF);
end
if Build.VERSION.SDK_INT >= Build.VERSION_CODES.M then
  activity.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR | View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR);
end
activity.setContentView(loadlayout(layout))


URLserver="https://defexgg.000webhostapp.com/"

swipeRefreshMember.setProgressViewOffset(true,0, 64)
swipeRefreshMember.setColorSchemeColors({0xFFFF65FC,0xFF2CFFFC})
swipeRefreshMember.setProgressBackgroundColorSchemeColor(0x9FFFFF55)

swipeRefreshMember.setOnRefreshListener(SwipeRefreshLayout.OnRefreshListener({
  onRefresh = function()
    onResume()
  end
}))

function onResume()
  swipeRefreshMember.setRefreshing(true)
  Http.get(URLserver.."listUsername.php",nil,"utf8",nil,function(code,body,cookie,header)
    if code==200 then
      loadstring(body)()
      Http.get(URLserver.."listPassword.php",nil,"utf8",nil,function(code,body,cookie,header)
        if code==200 then
          loadstring(body)()
          Http.get(URLserver.."listUUID.php",nil,"utf8",nil,function(code,body,cookie,header)
            if code==200 then
              loadstring(body)()
              Http.get(URLserver.."listExpired.php",nil,"utf8",nil,function(code,body,cookie,header)
                if code==200 then
                  swipeRefreshMember.setRefreshing(false)
                  loadstring(body)()
                  data={}
                  adp=LuaAdapter(activity,data,memberitem)
                  for n=1,jumlah do
                    table.insert(data,{
                      username={
                        text=tostring(username[n]),
                      },
                      uuid={
                        src=tostring(uuid[n]),
                      },
                      expired={
                        text=tostring(expired[n]),
                      },
                      btnUpdate={
                        onClick=function()

                          import "update"
                          dialog = AlertDialogBuilder(this);
                          dialog.setView(loadlayout(update))
                          dialog.setCancelable(true)
                          dialog.show();

                          animation = AnimationUtils.loadAnimation(activity,android.R.anim.fade_in)
                          layoutAnimation = LayoutAnimationController(animation)
                          layoutAnimation.setOrder(LayoutAnimationController.ORDER_NORMAL)
                          layoutAnimation.setDelay(0.3)
                          animationLayout.setLayoutAnimation(layoutAnimation)

                          txtUsername.setText(username[n])
                          txtPassword.setText(password[n])
                          txtUUID.setText(uuid[n])
                          txtExpired.setText(expired[n])

                          expType=""
                          function oneDay.OnCheckedChangeListener()
                            if oneDay.checked then
                              expType="1 days"
                            end
                          end
                          function oneWeek.OnCheckedChangeListener()
                            if oneWeek.checked then
                              expType="1 week"
                            end
                          end
                          function twoWeek.OnCheckedChangeListener()
                            if twoWeek.checked then
                              expType="2 week"
                            end
                          end
                          function oneMonth.OnCheckedChangeListener()
                            if oneMonth.checked then
                              expType="1 month"
                            end
                          end

                          btnUpdate.onClick=function()
                            local username = txtUsername.text
                            local password = txtPassword.text
                            if !username || username == "" then
                              Toast.makeText(activity, "Username is required.",Toast.LENGTH_SHORT).show()
                             elseif !password || password == "" then
                              Toast.makeText(activity, "Password is required.",Toast.LENGTH_SHORT).show()
                             else
                              UpdateUser()
                            end
                          end

                          function UpdateUser()
                            local username = txtUsername.text
                            local password = txtPassword.text
                            local uuid = txtUUID.text
                            local dl=ProgressDialog.show(activity,nil,'Please wait!')
                            dl.show()
                            Http.post(URLserver.."update.php","username="..username.."&password="..password.."&uuid="..uuid.."&expType="..expType,nil,"utf8",nil,function(code,body,cookie,header)
                              local a=0
                              local tt=Ticker()
                              tt.start()
                              tt.onTick=function()
                                a=a+1
                                if a==5 then
                                  dl.dismiss()
                                  tt.stop()
                                  if code == 200 then
                                    if body:match("Update success") then
                                      onResume()
                                      dialog.dismiss()
                                      Toast.makeText(activity, "Update success.",Toast.LENGTH_SHORT).show()
                                     elseif body:match("Username not registered") then
                                      Toast.makeText(activity, "Username not registered.",Toast.LENGTH_SHORT).show()
                                     elseif body:match("Update failed") then
                                      Toast.makeText(activity, "Update failed.",Toast.LENGTH_SHORT).show()
                                    end
                                   else
                                    Toast.makeText(activity, "Can't connect to server.",Toast.LENGTH_SHORT).show()
                                  end
                                end
                              end
                            end);
                          end

                        end
                      },
                      btnDelete={
                        onClick=function()
                          local dl=ProgressDialog.show(activity,nil,'Please wait!')
                          dl.show()
                          Http.post(URLserver.."delete.php","username="..username[n],nil,"utf8",nil,function(code,body,cookie,header)
                            local a=0
                            local tt=Ticker()
                            tt.start()
                            tt.onTick=function()
                              a=a+1
                              if a==5 then
                                dl.dismiss()
                                tt.stop()
                                if code == 200 then
                                  if body:match("Delete success") then
                                    onResume()
                                    Toast.makeText(activity, "Delete success.",Toast.LENGTH_SHORT).show()
                                   elseif body:match("Username not registered") then
                                    Toast.makeText(activity, "Username not registered.",Toast.LENGTH_SHORT).show()
                                   elseif body:match("Delete failed") then
                                    Toast.makeText(activity, "Delete failed.",Toast.LENGTH_SHORT).show()
                                  end
                                 else
                                  Toast.makeText(activity, "Can't connect to server.",Toast.LENGTH_SHORT).show()
                                end
                              end
                            end
                          end);
                        end
                      },
                    })
                  end
                  listMember.Adapter=adp
                 else
                  onResume()
                end
              end);
             else
              onResume()
            end
          end);
         else
          onResume()
        end
      end);
     else
      onResume()
    end
  end);
end

btnRegister.onClick=function()

  import "register"
  dialog = AlertDialogBuilder(this);
  dialog.setView(loadlayout(register))
  dialog.setCancelable(true)
  dialog.show();

  animation = AnimationUtils.loadAnimation(activity,android.R.anim.fade_in)
  layoutAnimation = LayoutAnimationController(animation)
  layoutAnimation.setOrder(LayoutAnimationController.ORDER_NORMAL)
  layoutAnimation.setDelay(0.3)
  animationLayout.setLayoutAnimation(layoutAnimation)

  expType="1 days"
  function oneDay.OnCheckedChangeListener()
    if oneDay.checked then
      expType="1 days"
    end
  end
  function oneWeek.OnCheckedChangeListener()
    if oneWeek.checked then
      expType="1 week"
    end
  end
  function twoWeek.OnCheckedChangeListener()
    if twoWeek.checked then
      expType="2 week"
    end
  end
  function oneMonth.OnCheckedChangeListener()
    if oneMonth.checked then
      expType="1 month"
    end
  end

  btnCreate.onClick=function()
    local username = txtUsername.text
    local password = txtPassword.text
    if !username || username == "" then
      Toast.makeText(activity, "Username is required.",Toast.LENGTH_SHORT).show()
     elseif !password || password == "" then
      Toast.makeText(activity, "Password is required.",Toast.LENGTH_SHORT).show()
     else
      CreateNewUser()
    end
  end

  function CreateNewUser()
    local username = txtUsername.text
    local password = txtPassword.text
    local dl=ProgressDialog.show(activity,nil,'Please wait!')
    dl.show()
    Http.post(URLserver.."register.php","username="..username.."&password="..password.."&expType="..expType,nil,"utf8",nil,function(code,body,cookie,header)
      local a=0
      local tt=Ticker()
      tt.start()
      tt.onTick=function()
        a=a+1
        if a==5 then
          dl.dismiss()
          tt.stop()
          if code == 200 then
            if body:match("Register success") then
              onResume()
              dialog.dismiss()
              Toast.makeText(activity, "Register success.",Toast.LENGTH_SHORT).show()
             elseif body:match("Already registered") then
              Toast.makeText(activity, "Username already registered.",Toast.LENGTH_SHORT).show()
             elseif body:match("Register failed") then
              Toast.makeText(activity, "Register failed.",Toast.LENGTH_SHORT).show()
            end
           else
            Toast.makeText(activity, "Can't connect to server.",Toast.LENGTH_SHORT).show()
          end
        end
      end
    end);
  end
end

import "register"
import "android.graphics.Paint"
import "android.graphics.Typeface"
import "memberitem"
tx1.setTypeface(Typeface.createFromFile(activity.getLuaDir("res/4.ttf")));






