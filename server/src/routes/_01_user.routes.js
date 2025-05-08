import { Router } from "express"
import { registerUser,loginUser, logoutUser } from "../controller/_01_user.controller.js"
import {upload} from "../middleware/_01_multer.middle_ware.js"
import { verifyJWT } from "../middleware/_02_auth.middleware.js";

const userRouter=Router()


userRouter
.route( '/register')
.post(
    upload.fields(//middle ware, before registering pls add fields called avatar and coverImage in request, so that we can access later like req.body.avatar[0].path
        [
            {
                name:"avatar",
                maxCount:1,
            },
            {
                name:"coverImage",
                maxCount:1,
            }
        ]
    ),
    registerUser
);

userRouter
.route('/login')
.post(
    loginUser,
)

userRouter
.route('/logout')
.post(
    verifyJWT,//middleware to append user field to req after matching actuall  accessToken and accessToken passed to req with cookie
    logoutUser
)

   

export {userRouter}